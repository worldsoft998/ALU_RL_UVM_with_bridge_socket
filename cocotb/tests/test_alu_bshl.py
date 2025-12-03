import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, Lock
import json, socket, threading, os, time, uuid
from cocotb.handle import SimHandleBase

LISTEN_HOST = '127.0.0.1'
LISTEN_PORT = 7777
MAILBOX_IN = 'bshl_mailbox/in'
MAILBOX_OUT = 'bshl_mailbox/out'

def write_apply_file(req_id, a, b, op):
    # find an index slot to write to (0..999)
    for i in range(1000):
        fname = os.path.join(MAILBOX_IN, f"apply_{i}.txt")
        if not os.path.exists(fname):
            with open(fname, 'w') as f:
                f.write(f"{req_id} {a} {b} {op}\n")
            return fname
    raise RuntimeError('No mailbox slot free')

def wait_for_file(path, timeout=5.0, poll=0.001):
    t0 = time.time()
    while time.time() - t0 < timeout:
        if os.path.exists(path):
            return True
        time.sleep(poll)
    return False

def read_result_file(req_id):
    resfile = os.path.join(MAILBOX_OUT, f"result_{req_id}.txt")
    if not wait_for_file(resfile, timeout=5.0):
        return None
    with open(resfile, 'r') as f:
        line = f.readline().strip()
    # result format: result carry zero latency_ns
    toks = line.split()
    if len(toks) >= 4:
        return {'result': int(toks[0]), 'carry': int(toks[1]), 'zero': int(toks[2]), 'latency_ns': int(toks[3])}
    return None

def write_ack_file(req_id):
    ackfile = os.path.join(MAILBOX_OUT, f"ack_{req_id}.txt")
    # wait until ack file exists (bridge agent writes it)
    return wait_for_file(ackfile, timeout=2.0)

class SocketBridgeServer(threading.Thread):
    def __init__(self, dut, host=LISTEN_HOST, port=LISTEN_PORT):
        super().__init__(daemon=True)
        self.host = host
        self.port = port
        self.dut = dut
        self.sock = None
        self.stop_flag = threading.Event()

    def run(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.bind((self.host, self.port))
        self.sock.listen(1)
        self.dut._log.info(f"BSHL socket server listening on {self.host}:{self.port}")
        while not self.stop_flag.is_set():
            try:
                conn, addr = self.sock.accept()
                self.dut._log.info(f"BSHL: connection from {addr}")
                f = conn.makefile('rwb')
                while True:
                    line = f.readline()
                    if not line:
                        break
                    try:
                        msg = json.loads(line.decode('utf-8'))
                    except Exception as e:
                        self.dut._log.warning(f"BSHL: json parse error: {e}")
                        break
                    if msg.get('type') == 'apply':
                        req_id = msg.get('req_id', str(uuid.uuid4()))
                        a = msg.get('a', 0)
                        b = msg.get('b', 0)
                        op = msg.get('op', 0)
                        # write apply file for UVM bridge agent
                        write_apply_file(req_id, a, b, op)
                        # wait for ack file from UVM bridge agent
                        if write_ack_file(req_id):
                            ack = {'type':'ack', 'req_id': req_id, 'status':'accepted'}
                            f.write((json.dumps(ack) + '\n').encode('utf-8'))
                            f.flush()
                        else:
                            # ack timeout
                            nack = {'type':'ack', 'req_id': req_id, 'status':'noack'}
                            f.write((json.dumps(nack) + '\n').encode('utf-8'))
                            f.flush()
                            continue
                        # wait for result from UVM bridge
                        res = None
                        t0 = time.time()
                        while time.time() - t0 < 5.0:
                            resdict = read_result_file(req_id)
                            if resdict is not None:
                                res = {'type':'result', 'req_id': req_id, **resdict}
                                break
                            time.sleep(0.001)
                        if res is None:
                            # timeout result
                            fail = {'type':'result', 'req_id': req_id, 'error':'timeout'}
                            f.write((json.dumps(fail) + '\n').encode('utf-8'))
                            f.flush()
                        else:
                            f.write((json.dumps(res) + '\n').encode('utf-8'))
                            f.flush()
                conn.close()
            except Exception as e:
                self.dut._log.warning(f"BSHL server exception: {e}")
                time.sleep(0.1)
        if self.sock:
            self.sock.close()

    def stop(self):
        self.stop_flag.set()
        # create dummy connection to unblock accept
        try:
            s = socket.create_connection((self.host, self.port), timeout=0.5)
            s.close()
        except Exception:
            pass

@cocotb.test()
async def test_bshl_bridge(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    # ensure mailbox dirs exist
    os.makedirs(MAILBOX_IN, exist_ok=True)
    os.makedirs(MAILBOX_OUT, exist_ok=True)
    server = SocketBridgeServer(dut)
    server.start()
    dut._log.info("BSHL bridge server started")
    # run for some time to allow external RL client to connect and send messages
    await Timer(2000, units='ns')
    server.stop()
    await Timer(10, units='ns')
    dut._log.info("BSHL bridge server stopped and cocotb test finished")
