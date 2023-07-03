#!/usr/bin/python3
from pyq3serverlist import Server
from pyq3serverlist.exceptions import PyQ3SLError, PyQ3SLTimeoutError
import json
import os
import re

# supress pygame support banner
os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "hide"
import pygame

pygame.mixer.init()
alert_sound = pygame.mixer.Sound("sounds/sonar.ogg")  # loading the ogg file

# TD substring
rules = {
    "TD 🪖": "{-TD-}",
    "hacker 🤖": "pengy|ezee|artemus|eyemaster",
}

# TD 74.91.121.154:27960
servers = {
    "TD": Server("74.91.121.154", 27960),
    "RFA": Server("74.91.112.64", 27960),
    "PUBZAO": Server("190.102.43.217", 27960),
}


def divider(n=56):
    return "-" * n


try:
    user_found = False
    for server_name, server in servers.items():
        info = server.get_status()
        players = info.get("players")
        print_str = [f"{server_name}({len(players)})"]
        print_str.append(
            "{:<16} {:<24} {:<8} {:<8}".format("rule", "Name", "points", "ping")
        )
        if len(players) != 0:
            for player in players:
                for rule_name, rule in rules.items():
                    if re.search(rule, player.get("name")):
                        user_found = True
                        name = player.get("name")
                        points = player.get("frags")
                        ping = player.get("ping")
                        print_str.append(
                            "{:<16} {:<24} {:<8} {:<8}".format(
                                rule_name, name, points, ping
                            )
                        )
        print_str.append(divider())
        print("\n".join(print_str))
    # divider()
    if user_found:
        alert_sound.play()
        # print(json.dumps(info, indent=4))
# print 56 dashes
except (PyQ3SLError, PyQ3SLTimeoutError) as e:
    print(e)
