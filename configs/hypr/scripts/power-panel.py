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

        # Нижний правый угол экрана
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.BOTTOM, 14)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.RIGHT, 14)

        self.set_decorated(False)

        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(b"""
            window, .background {
                background-color: #11111b;
                border-radius: 16px;
                border: 1px solid #89b4fa;
            }
            button {
                background-image: none;
                background-color: #1e1e2e;
                color: #cdd6f4;
                border: 1px solid #89b4fa;
                border-radius: 10px;
                min-width: 46px;
                min-height: 46px;
                padding: 0px;
                font-size: 18px;
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

        main_hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        main_hbox.set_margin_top(10)
        main_hbox.set_margin_bottom(10)
        main_hbox.set_margin_start(10)
        main_hbox.set_margin_end(10)
        self.add(main_hbox)

        # Иконки в стиле Nerd Font (Font Awesome), без подписей
        actions = [
            ("\uf023", ["hyprlock"]),                              # lock
            ("\uf186", ["systemctl", "suspend"]),                  # moon / sleep
            ("\uf08b", ["hyprctl", "dispatch", "exit"]),           # sign-out
            ("\uf021", ["systemctl", "reboot"]),                   # refresh
            ("\uf011", ["systemctl", "poweroff"]),                 # power-off
        ]

        for icon, cmd in actions:
            btn = Gtk.Button(label=icon)
            btn.connect("clicked", self.on_action, cmd)
            main_hbox.pack_start(btn, False, False, 0)

        self.show_all()

    def on_action(self, widget, cmd):
        subprocess.Popen(cmd)
        self.destroy()


if __name__ == "__main__":
    win = PowerPanel()
    win.connect("destroy", Gtk.main_quit)
    Gtk.main()
