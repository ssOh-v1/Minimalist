#!/usr/bin/env python3
import os
import gi
import subprocess

gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, GtkLayerShell, GLib, Gdk, GdkPixbuf


class SpotifyPanel(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)

        settings = Gtk.Settings.get_default()
        settings.set_property("gtk-theme-name", "Adwaita-dark")
        settings.set_property("gtk-application-prefer-dark-theme", True)

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_namespace(self, "spotify-panel")
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.TOP)

        # Привязка к левому нижнему углу (вплотную)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.LEFT, 0)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.BOTTOM, 0)

        # Компактная горизонтальная панель
        self.set_size_request(465, 180)
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
                padding: 6px 10px;
                min-width: 36px;
                min-height: 36px;
                box-shadow: none;
                text-shadow: none;
            }
            button:hover {
                background-color: #89b4fa;
                color: #1e1e2e;
            }
            scale trough {
                background-color: #1e1e2e;
                border-radius: 4px;
                min-height: 8px;
            }
            scale highlight {
                background-color: #89b4fa;
                border-radius: 4px;
            }
            scale slider {
                background-color: #cdd6f4;
                border-radius: 50%;
                min-width: 14px;
                min-height: 14px;
                margin: -3px;
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

        # Вертикальный контейнер (для двух рядов: верхний и ползунки)
        main_vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        main_vbox.set_margin_top(15)
        main_vbox.set_margin_bottom(15)
        main_vbox.set_margin_start(15)
        main_vbox.set_margin_end(15)
        self.add(main_vbox)

        # Верхний ряд: текст + кнопки
        top_hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=15)
        main_vbox.pack_start(top_hbox, False, False, 0)

        # Левая часть: заголовок и название трека
        left_vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        top_hbox.pack_start(left_vbox, True, True, 0)

        title = Gtk.Label()
        title.set_markup("<b>🎵 Spotify</b>")
        title.set_xalign(0)
        left_vbox.pack_start(title, False, False, 0)

        self.track_label = Gtk.Label()
        self.track_label.set_xalign(0)
        self.track_label.set_line_wrap(True)
        self.track_label.set_text("Spotify не играет")
        left_vbox.pack_start(self.track_label, False, False, 0)

        # Правая часть: кнопки
        controls = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)

        prev_btn = Gtk.Button(label="⏮")
        prev_btn.set_tooltip_text("Предыдущий трек")
        prev_btn.connect("clicked", self.on_prev)

        play_btn = Gtk.Button(label="⏯")
        play_btn.set_tooltip_text("Пауза / Воспроизведение")
        play_btn.connect("clicked", self.on_play)

        next_btn = Gtk.Button(label="⏭")
        next_btn.set_tooltip_text("Следующий трек")
        next_btn.connect("clicked", self.on_next)

        controls.pack_start(prev_btn, False, False, 0)
        controls.pack_start(play_btn, False, False, 0)
        controls.pack_start(next_btn, False, False, 0)
        top_hbox.pack_start(controls, False, False, 0)

        # Нижний ряд: ползунки на всю ширину
        self.seek_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.seek_scale.set_draw_value(False)
        self.seek_scale.set_hexpand(True)
        self.seek_scale.connect("change-value", self.on_seek)
        main_vbox.pack_start(self.seek_scale, False, False, 0)

        volume_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        volume_box.set_hexpand(True)

        volume_icon = Gtk.Label(label="🔊")
        volume_box.pack_start(volume_icon, False, False, 0)

        self.volume_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.volume_scale.set_draw_value(False)
        self.volume_scale.set_hexpand(True)
        self.volume_scale.connect("change-value", self.on_volume_change)
        volume_box.pack_start(self.volume_scale, True, True, 0)

        main_vbox.pack_start(volume_box, False, False, 0)

        self.update_track_info()
        GLib.timeout_add_seconds(1, self.update_track_info)

        self.show_all()

    def on_prev(self, widget):
        subprocess.Popen(["playerctl", "--player=spotify", "previous"])

    def on_play(self, widget):
        subprocess.Popen(["playerctl", "--player=spotify", "play-pause"])

    def on_next(self, widget):
        subprocess.Popen(["playerctl", "--player=spotify", "next"])

    def on_seek(self, widget, scroll_type, value):
        try:
            length = subprocess.check_output(
                ["playerctl", "--player=spotify", "metadata", "mpris:length"],
                stderr=subprocess.DEVNULL
            ).decode().strip()
            length = int(length) // 1000000
            new_pos = int((value / 100) * length)
            subprocess.Popen(["playerctl", "--player=spotify", "position", str(new_pos)])
        except Exception:
            pass
        return False

    def on_volume_change(self, widget, scroll_type, value):
        try:
            subprocess.Popen(["playerctl", "--player=spotify", "volume", str(value / 100)])
        except Exception:
            pass
        return False

    def update_track_info(self):
        try:
            title = subprocess.check_output(
                ["playerctl", "--player=spotify", "metadata", "title"],
                stderr=subprocess.DEVNULL
            ).decode().strip()
            artist = subprocess.check_output(
                ["playerctl", "--player=spotify", "metadata", "artist"],
                stderr=subprocess.DEVNULL
            ).decode().strip()
            self.track_label.set_text(title + "\n" + artist)

            try:
                position = subprocess.check_output(
                    ["playerctl", "--player=spotify", "position"],
                    stderr=subprocess.DEVNULL
                ).decode().strip()
                length = subprocess.check_output(
                    ["playerctl", "--player=spotify", "metadata", "mpris:length"],
                    stderr=subprocess.DEVNULL
                ).decode().strip()
                position = float(position)
                length = int(length) / 1000000
                if length > 0:
                    percent = (position / length) * 100
                    self.seek_scale.set_value(percent)
            except Exception:
                pass

            try:
                volume = subprocess.check_output(
                    ["playerctl", "--player=spotify", "volume"],
                    stderr=subprocess.DEVNULL
                ).decode().strip()
                self.volume_scale.set_value(float(volume) * 100)
            except Exception:
                pass
        except subprocess.CalledProcessError:
            self.track_label.set_text("Spotify не играет")
        return True


if __name__ == "__main__":
    win = SpotifyPanel()
    win.connect("destroy", Gtk.main_quit)
    Gtk.main()
