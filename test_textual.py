from textual.app import App, ComposeResult
from textual.widgets import Static

class TestApp(App):
    def compose(self) -> ComposeResult:
        yield Static("Textual works!")

if __name__ == "__main__":
    app = TestApp()
    app.run()
