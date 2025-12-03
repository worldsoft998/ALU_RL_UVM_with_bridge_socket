Recommended BSHL message handshake (JSON over socket or provided BSHL channel):

1) Controller -> UVM (via cocotb-BSHL): APPLY
   { "type":"apply", "req_id": "<uuid>", "a": <0-255>, "b": <0-255>, "op": <0-7> }

2) UVM -> Controller: ACK
   { "type":"ack", "req_id": "<uuid>", "status":"accepted" }

3) After DUT settled: UVM -> Controller: RESULT
   { "type":"result", "req_id":"<uuid>", "result":<0-255>, "carry":0/1, "zero":0/1, "latency_ns": <int> }

Timeout handling: if ack not received by controller in T1 ms, retry. If no result within T2 ms, mark sample as failed.

This protocol maps cleanly to Gym environments (step() -> send APPLY, wait for RESULT).
