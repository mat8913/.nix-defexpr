use gtk::prelude::*;
use gtk::{self, gio, glib};

fn main() -> glib::ExitCode {
    let app = gtk::Application::builder()
        .flags(gio::ApplicationFlags::NON_UNIQUE | gio::ApplicationFlags::HANDLES_OPEN)
        .build();

    app.connect_open(handle_open);

    app.run()
}

fn handle_open(app: &gtk::Application, files: &[gio::File], _hint: &str) {
    let mut txt = String::new();
    for file in files {
        txt.push_str(file.uri().as_str());
        txt.push('\n');
    }

    let text_view = gtk::TextView::builder().build();

    text_view.buffer().set_text(&txt);

    let window = gtk::ApplicationWindow::builder()
        .application(app)
        .title("Open URL")
        .child(&text_view)
        .build();

    window.present();
}
