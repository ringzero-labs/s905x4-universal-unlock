#!/usr/bin/env python3
"""Pair with or control Android TV Remote without hard-coded identity."""

import argparse
import asyncio
from pathlib import Path

from androidtvremote2 import AndroidTVRemote


async def run() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("host")
    parser.add_argument("--name", default="Linux Android TV remote")
    parser.add_argument("--state-dir", type=Path, default=Path(".androidtv-remote"))
    parser.add_argument("--pair", action="store_true")
    parser.add_argument("--launch")
    parser.add_argument("--key", action="append", default=[])
    parser.add_argument("--text")
    parser.add_argument("--wait", type=float, default=2.0)
    args = parser.parse_args()

    args.state_dir.mkdir(mode=0o700, parents=True, exist_ok=True)
    cert = args.state_dir / "remote-cert.pem"
    key = args.state_dir / "remote-key.pem"
    remote = AndroidTVRemote(args.name, str(cert), str(key), args.host)

    if args.pair:
        await remote.async_generate_cert_if_missing()
        device_name, _ = await remote.async_get_name_and_mac()
        print(f"Pairing with {device_name}")
        await remote.async_start_pairing()
        code = input("Pairing code shown on TV: ").strip()
        await remote.async_finish_pairing(code)
        print("Pairing complete")
        return

    await remote.async_connect()
    print(f"Connected; current app: {remote.current_app}")
    if args.launch:
        remote.send_launch_app_command(args.launch)
    for key_name in args.key:
        remote.send_key_command(key_name)
        await asyncio.sleep(0.4)
    if args.text:
        remote.send_text(args.text)
    await asyncio.sleep(args.wait)
    print(f"Current app: {remote.current_app}")
    remote.disconnect()


if __name__ == "__main__":
    asyncio.run(run())
