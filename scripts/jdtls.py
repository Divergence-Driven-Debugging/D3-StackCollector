from pathlib import Path

from lspclient import LSPClient

class JDTLS:

    def __init__(self, client: LSPClient, bundles: list[str]):
        self.client = client
        self.bundles = bundles
    
    def initialize(self, project_dir: Path):

        root_uri = project_dir.as_uri()

        self.client.request(
            "initialize",
            {
                "processId": None,
                "capabilities": {},
                "initializationOptions": {
                    "bundles": self.bundles
                },
                "rootUri": root_uri,
                "workspaceFolders": [
                    {
                        "uri": root_uri,
                        "name": project_dir.name
                    }
                ],
            }
        )

        self.client.notify("initialized", {})
    
    def execute_command(self, command: str, arguments: list = []):
        return self.client.request(
            "workspace/executeCommand",
            {
                "command": command,
                "arguments": arguments
            }
        )
    
    def shutdown(self):
        self.client.request("shutdown", {})
        self.client.notify("exit", {})