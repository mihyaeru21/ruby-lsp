import * as vscode from 'vscode';
import { LanguageClient, LanguageClientOptions, ServerOptions, TransportKind } from 'vscode-languageclient/node';

let client: LanguageClient;

export function activate(context: vscode.ExtensionContext) {
	const server = {
		command: "bundle",
		args: ["exec", "ruby-lsp"],
		options: {
			cwd: vscode.workspace.workspaceFolders![0].uri.fsPath
		},
		transport: TransportKind.stdio
	};

	const serverOptions: ServerOptions = {
		run: server,
		debug: server
	};

	const clientOptions: LanguageClientOptions = {
		documentSelector: [{ scheme: 'file', language: 'ruby' }],
		synchronize: {
			fileEvents: vscode.workspace.createFileSystemWatcher('**/*.rb')
		}
	};

	client = new LanguageClient('Shopify.ruby-lsp', 'Ruby LSP', serverOptions, clientOptions);
	client.start();
}

// this method is called when your extension is deactivated
export function deactivate() {
	if (!client) {
		return undefined;
	}
	return client.stop();
}
