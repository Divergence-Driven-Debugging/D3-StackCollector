from pathlib import Path


class JDTLS:
    """
    Convenience wrapper around the Eclipse JDT Language Server.

    Provides helper methods for workspace initialization and
    command execution.
    """

    def __init__(self, client, bundles):
        """Create a JDTLS wrapper using the given LSP client."""
        self.client = client
        self.bundles = bundles

    def initialize(self, project_dir):
        """Initialize JDTLS for the specified project directory."""

        root_uri = project_dir.as_uri()

        self.client.request(
            "initialize",
            {
                "processId": None,
                "capabilities": {},
                "initializationOptions": {"bundles": self.bundles},
                "rootUri": root_uri,
                "workspaceFolders": [{"uri": root_uri, "name": project_dir.name}],
            },
        )

        self.client.notify("initialized", {})

    def execute_command(self, command):
        """Execute a JDTLS workspace command."""

        return self.client.request(
            "workspace/executeCommand", {"command": command, "arguments": []}
        )

    def shutdown(self):
        """Gracefully shut down the language server."""

        self.client.request("shutdown", {})
        self.client.notify("exit", {})
