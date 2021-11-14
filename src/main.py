import sys
import time
import subprocess as sp

from http.server import HTTPServer, BaseHTTPRequestHandler

QEMU_START_STR = """
qemu-system-x86_64 \
  -enable-kvm \
  -m 512 \
  -hda {disk} \
  -snapshot \
  -nographic \
  -netdev user,id=ssh_net,hostfwd=tcp:127.0.0.1:{port}-:22 \
  -device e1000,netdev=ssh_net
"""

WSSH_PROCESS = sp.Popen('wssh')
free_port = 12000

if WSSH_PROCESS.returncode is not None:
    raise Exception("Could not start wssh")

def popen_qemu():
    global free_port
    qemu_process = sp.Popen(QEMU_START_STR.format(disk=sys.argv[1],
                                                  port=free_port),
                            shell=True,
                            stdout=sp.PIPE)
    free_port += 1
    return (qemu_process, free_port)


QEMU_INSTANCES = [popen_qemu(),popen_qemu()]

class RedirectHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        qemu_process, qemu_port = QEMU_INSTANCES.pop(0)
        QEMU_INSTANCES.append(popen_qemu())
        redirect_url = "http://localhost:8888/?hostname=localhost&username=root&password=MQo=&port={}&command=tmux;poweroff"
        self.send_response(302)
        self.send_header('Location', redirect_url.format(qemu_port))
        while True:
            line = qemu_process.stdout.readline()
            if b'Welcome to Alpine' in line:
                time.sleep(2)
                break
        self.end_headers()

HTTPServer(("", 80), RedirectHandler).serve_forever()
