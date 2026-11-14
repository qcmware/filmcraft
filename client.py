import json
import os
import socket
import argparse
import sys
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("--host", default="127.0.0.1")
parser.add_argument("--port", type=int, default=9876)
request_source = parser.add_mutually_exclusive_group()
request_source.add_argument(
    "--request",
    default="server-args.json",
    help="Archivo JSON que se enviará a FilmCraft",
)
request_source.add_argument(
    "--json-text",
    help="Texto JSON que se enviará a FilmCraft",
)
parser.add_argument("--name", default='Nuevo proyecto', help="Nombre del proyecto nuevo")
parser.add_argument(
    "--paths",
    nargs="+",
    help="Una o más rutas de medios que se añadirán al proyecto",
)
args = parser.parse_args()


def parse_json_text(json_text):
    try:
        return json.loads(json_text)
    except json.JSONDecodeError as error:
        try:
            position = 0

            def skip_whitespace():
                nonlocal position
                while position < len(json_text) and json_text[position].isspace():
                    position += 1

            def parse_value():
                nonlocal position
                skip_whitespace()
                if position >= len(json_text):
                    raise ValueError("unexpected end of input")

                if json_text[position] == "{":
                    position += 1
                    result = {}
                    skip_whitespace()
                    if position < len(json_text) and json_text[position] == "}":
                        position += 1
                        return result
                    while True:
                        skip_whitespace()
                        if position >= len(json_text):
                            raise ValueError("missing object key")
                        if json_text[position] in "\"'":
                            quote = json_text[position]
                            end = json_text.find(quote, position + 1)
                            if end < 0:
                                raise ValueError("unterminated object key")
                            key = json_text[position + 1:end]
                            position = end + 1
                        else:
                            start = position
                            while position < len(json_text) and json_text[position] not in ":,}":
                                position += 1
                            key = json_text[start:position].strip()
                        skip_whitespace()
                        if position >= len(json_text) or json_text[position] != ":" or not key:
                            raise ValueError("expected object key followed by ':'")
                        position += 1
                        result[key] = parse_value()
                        skip_whitespace()
                        if position >= len(json_text):
                            raise ValueError("missing '}'")
                        if json_text[position] == "}":
                            position += 1
                            return result
                        if json_text[position] != ",":
                            raise ValueError("expected ',' or '}'")
                        position += 1

                if json_text[position] == "[":
                    position += 1
                    result = []
                    skip_whitespace()
                    if position < len(json_text) and json_text[position] == "]":
                        position += 1
                        return result
                    while True:
                        result.append(parse_value())
                        skip_whitespace()
                        if position >= len(json_text):
                            raise ValueError("missing ']'")
                        if json_text[position] == "]":
                            position += 1
                            return result
                        if json_text[position] != ",":
                            raise ValueError("expected ',' or ']'")
                        position += 1

                if json_text[position] in "\"'":
                    quote = json_text[position]
                    end = json_text.find(quote, position + 1)
                    if end < 0:
                        raise ValueError("unterminated string")
                    value = json_text[position + 1:end]
                    position = end + 1
                    return value

                start = position
                while position < len(json_text) and json_text[position] not in ",}]":
                    position += 1
                token = json_text[start:position].strip()
                if token == "true":
                    return True
                if token == "false":
                    return False
                if token == "null":
                    return None
                try:
                    return json.loads(token)
                except json.JSONDecodeError:
                    return token

            result = parse_value()
            skip_whitespace()
            if position != len(json_text):
                raise ValueError("unexpected trailing text")
            return result
        except (ValueError, json.JSONDecodeError):
            raise error


if args.json_text is not None:
    try:
        request = parse_json_text(args.json_text)
    except json.JSONDecodeError as error:
        raise SystemExit(f"El argumento --json-text no contiene JSON válido: {error}") from error
else:
    try:
        with Path(args.request).open("r", encoding="utf-8") as request_file:
            request = json.load(request_file)
    except OSError as error:
        raise SystemExit(f"No se pudo leer {args.request}: {error}") from error
    except json.JSONDecodeError as error:
        raise SystemExit(f"El archivo {args.request} no contiene JSON válido: {error}") from error

requests = request if isinstance(request, list) else [request]
for index, request_item in enumerate(requests, start=1):
    if not isinstance(request_item, dict):
        raise SystemExit(f"La solicitud {index} debe ser un objeto JSON.")

    request_params = request_item.get("params")
    if request_params is not None:
        if not isinstance(request_params, dict):
            raise SystemExit(f"La solicitud {index} debe contener un objeto params.")

        command_params = request_params.get("params")
        if command_params is not None:
            if not isinstance(command_params, dict):
                raise SystemExit(f"La solicitud {index} debe contener un objeto params.params.")

            command_params["name"] = args.name
            command_params["paths"] = args.paths

token = os.environ.get("FILMCRAFT_CONTROL_TOKEN")
if not token:
    raise SystemExit("Define FILMCRAFT_CONTROL_TOKEN antes de ejecutar el cliente.")
for request_item in requests:
    request_item["token"] = token

host = args.host
port = args.port

failed = False
with socket.create_connection((host, port)) as sock:
    with sock.makefile("r", encoding="utf-8", newline="\n") as response:
        for index, request_item in enumerate(requests, start=1):
            try:
                sock.sendall((json.dumps(request_item) + "\n").encode())
                line = response.readline()
            except OSError as error:
                raise SystemExit(f"No se pudo procesar la solicitud {index}: {error}") from error
            if not line:
                raise SystemExit(f"FilmCraft cerró la conexión sin responder a la solicitud {index}.")

            try:
                reply = json.loads(line)
            except json.JSONDecodeError as error:
                raise SystemExit(f"Respuesta inválida para la solicitud {index}: {error}") from error
            if not isinstance(reply, dict):
                raise SystemExit(f"La respuesta de la solicitud {index} no es un objeto JSON.")

            print(json.dumps(reply, indent=2, ensure_ascii=False))
            if reply.get("ok") is False:
                failed = True

if failed:
    sys.exit(1)
