import argparse
from stable_baselines3 import PPO
from stable_baselines3.common.vec_env import DummyVecEnv
from gymnasium import spaces
from gymnasium.utils import seeding
from gymnasium import Env
import numpy as np
from gym_envs.alu_env import ALUEnv

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=7777)
    parser.add_argument("--timesteps", type=int, default=10000)
    args = parser.parse_args()

    env = ALUEnv(host=args.host, port=args.port)
    vec = DummyVecEnv([lambda: env])
    model = PPO('MlpPolicy', vec, verbose=1)
    model.learn(total_timesteps=args.timesteps)
    model.save('ppo_alu_policy')

if __name__ == '__main__':
    main()
