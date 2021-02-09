# Copyright 2021 Élerille
# 
# This file is part of Elerille::API::Sway.
#
# Elerille::API::Sway is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Elerille::API::Sway is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Elerille::API::Sway.  If not, see <https://www.gnu.org/licenses/>.

unit class Elerille::API::Sway::Output is export;

use Elerille::API::Sway::LowLevel;
use Elerille::API::Sway::OutputMode;
use Elerille::API::Sway::OutputRect;

has Elerille::API::Sway::LowLevel $!sway is built;

has Bool $.active;
has Bool $.adaptive-sync;
has $.border;
has $.current-border-width;

has OutputMode $.current-mode;
has Str $.current-workspace;

has OutputRect $.deco-rect;

has Bool $.dpms;

has $.floating-nodes;
has $.focus;
has Bool $.focused;
has $.fullscreen-mode;

has OutputRect $.geometry;

has $.id;
has $.layout;
has Str $.make;
has @.marks;
has $.max-render-time;
has Str $.model;
has OutputMode @.modes;
has Str $.name;
has @.nodes;
has @.orientation;
has $.percent;

#| For i3 compatibility
has $.primary;
has OutputRect $.rect;
has Rat $.scale;
has Str $.scale-filter;
has Str $.serial;
has Bool $.sticky;
has Str $.subpixel-hinting;
has Str $.transform;
has Str $.type;
has Bool $.urgent;
has $.window;
has OutputRect $.window-rect;


method new {
  %_<adaptive-sync> = %_<adaptive_sync_status> ne 'disabled';
  die "adaptive_sync_status value unknown" unless %_<adaptive_sync_status> eq 'disabled' | 'enabled';
  %_<adaptive_sync_status>:delete;

  for <current-border-width current-mode current-workspace 
  deco-rect floating-nodes fullscreen-mode scale-filter subpixel-hinting window-rect> {
    %_{$_} = %_{S:g/"-"/_/};
    %_{S:g/"-"/_/}:delete;
  }

  %_<current-mode> = OutputMode.new: |%_<current-mode>;
  my OutputMode @modes= @(%_<modes>.map({OutputMode.new: |%$_}));
  %_<modes> = @modes;
  %_<deco-rect>    = OutputRect.new: |%_<deco-rect>;
  %_<geometry>     = OutputRect.new: |%_<geometry>;
  %_<rect>     = OutputRect.new: |%_<rect>;
  %_<window-rect>    = OutputRect.new: |%_<window-rect>;

  return self.bless(|%_, :@modes);
}
