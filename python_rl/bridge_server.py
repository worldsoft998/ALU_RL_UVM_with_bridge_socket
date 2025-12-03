import socket
import threading
import json
import time
from http.server import BaseHTTPRequestHandler

def handle_client(conn, addr):
    f = conn.makefile('rwb')
    while True:
        line = f.readline()
        if not line:
            break
        try:
            msg = json.loads(line.decode('utf-8'))
        except Exception as e:
            break
        # Simple echo ack/result for testing without real simulator
        if msg.get('type') == 'apply':
            req_id = msg.get('req_id')
            ack = {'type':'ack', 'req_id': req_id, 'status':'accepted'}
            f.write((json.dumps(ack) + '\n').encode('utf-8'))
            f.flush()
            # fake compute latency
            time.sleep(0.001)
            result = {'type':'result', 'req_id': req_id, 'result': (msg['a'] + msg['b']) & 0xff, 'carry': ((msg['a']+msg['b'])>>8)&1, 'zero': 0, 'latency_ns': 100}
            f.write((json.dumps(result) + '\n').encode('utf-8'))
            f.flush()
    conn.close()

def main(host='127.0.0.1', port=7777):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((host, port))
    s.listen(5)
    print(f"Bridge server listening on {host}:{port}")
    try:
        while True:
            conn, addr = s.accept()
            threading.Thread(target=handle_client, args=(conn, addr), daemon=True).start()
    except KeyboardInterrupt:
        s.close()

if __name__ == '__main__':
    main()
