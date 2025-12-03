import gymnasium as gym
from gymnasium import spaces
import numpy as np
import socket
import json
import uuid
import time

class ALUEnv(gym.Env):
    """Gym environment that communicates with the simulator via a JSON socket (BSHL-style)."""
    metadata = {'render.modes': ['human']}
    def __init__(self, host='127.0.0.1', port=7777, timeout=5.0):
        super().__init__()
        # action: a(8bits), b(8bits), op(3bits) -> packed into discrete or Box
        # We'll use a discrete action space by flattening a,b,op: 256*256*8 ~ 524288 actions (large)
        # Instead, use a parameterized action: Box(3,) -> [a,b,op]
        self.action_space = spaces.Box(low=np.array([0,0,0]), high=np.array([255,255,7]), dtype=np.int32)
        # observation: last result, carry, zero, and simple coverage vector (8 ops coverage bits)
        self.observation_space = spaces.Box(low=0, high=255, shape=(11,), dtype=np.int32)
        self.host = host
        self.port = port
        self.timeout = timeout
        self.sock = None
    def connect(self):
        if self.sock is None:
            self.sock = socket.create_connection((self.host, self.port), timeout=self.timeout)
            self.sock_file = self.sock.makefile('rwb')
    def close(self):
        if self.sock:
            self.sock.close()
            self.sock = None
    def _send(self, msg):
        data = (json.dumps(msg) + "\n").encode('utf-8')
        self.sock.sendall(data)
    def _recv(self):
        line = self.sock_file.readline()
        if not line:
            raise EOFError("Socket closed")
        return json.loads(line.decode('utf-8'))
    def step(self, action):
        # action is array: [a,b,op]
        a = int(action[0])
        b = int(action[1])
        op = int(action[2])
        req = {"type":"apply", "req_id": str(uuid.uuid4()), "a":a, "b":b, "op":op}
        self.connect()
        self._send(req)
        # wait for ack
        start = time.time()
        ack = None
        while time.time() - start < self.timeout:
            resp = self._recv()
            if resp.get('type') == 'ack' and resp.get('req_id') == req['req_id']:
                ack = resp
                break
        if ack is None:
            # timeout
            return None, -1.0, True, {}
        # wait for result
        res = None
        start = time.time()
        while time.time() - start < self.timeout:
            resp = self._recv()
            if resp.get('type') == 'result' and resp.get('req_id') == req['req_id']:
                res = resp
                break
        if res is None:
            return None, -1.0, True, {}
        # build observation and reward
        obs = np.zeros(self.observation_space.shape, dtype=np.int32)
        obs[0] = res.get('result',0)
        obs[1] = res.get('carry',0)
        obs[2] = res.get('zero',0)
        # simple coverage vector placeholder
        # reward shaping: prefer non-zero results and exercising different ops
        reward = 0.0
        if obs[2] == 0:
            reward += 0.1
        reward += (op == 0) * 0.01
        done = False
        info = {'latency_ns': res.get('latency_ns',0)}
        return obs, reward, done, False, info
    def reset(self, seed=None, options=None):
        return np.zeros(self.observation_space.shape, dtype=np.int32), {}
    def render(self, mode='human'):
        pass
