#!/usr/bin/env python3
import gi
import subprocess

gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, GtkLayerShell, Gdk


class PowerPanel(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)

        settings = Gtk.Settings.get_default()
        settings.set_property("gtk-theme-name", "Adwaita-dark")
        settings.set_property("gtk-application-prefer-dark-theme", True)

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_namespace(self, "power-panel")
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.TOP)

        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 36)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.RIGHT, 10)

        self.set_size_request(240, 0)
        self.set_decorated(False)

        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(b"""
            window, .background {
                background-color: #11111b;
                border-radius: 20px;
                border: 1px solid #89b4fa;
            }
            label {
                color: #cdd6f4;
                font-size: 14px;
                background-color: transparent;
            }
            button {
                background-image: none;
                background-color: #1e1e2e;
                color: #cdd6f4;
                border: 1px solid #89b4fa;
                border-radius: 8px;
                padding: 8px 10px;
                min-height: 36px;
                box-shadow: none;
                text-shadow: none;
            }
            button:hover {
                background-color: #89b4fa;
                color: #1e1e2e;
            }
            box {
                background-color: #11111b;
            }
        """)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        main_vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        main_vbox.set_margin_top(15)
        main_vbox.set_margin_bottom(15)
        main_vbox.set_margin_start(15)
        main_vbox.set_margin_end(15)
        self.add(main_vbox)

        title = Gtk.Label()
        title.set_markup("<b>⏻ Питание</b>")
        title.set_xalign(0)
        main_vbox.pack_start(title, False, False, 4)

        actions = [
            ("🔒  Блокировка", ["hyprlock"]),
            ("🌙  Сон", ["systemctl", "suspend"]),
            ("🚪  Выход (SDDM)", ["hyprctl", "dispatch", "exit"]),
            ("🔄  Перезагрузка", ["systemctl", "reboot"]),
            ("⏻  Выключение", ["systemctl", "poweroff"]),
        ]

        for label_text, cmd in actions:
            btn = Gtk.Button(label=label_text)
            btn.connect("clicked", self.on_action, cmd)
            main_vbox.pack_start(btn, False, False, 0)

        self.show_all()

    def on_action(self, widget, cmd):
        subprocess.Popen(cmd)
        self.destroy()


if __name__ == "__main__":
    win = PowerPanel()
    win.connect("destroy", Gtk.main_quit)
    Gtk.main()
