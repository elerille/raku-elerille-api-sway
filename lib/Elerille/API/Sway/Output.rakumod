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

use Color;

enum ScaleFilter is export <linear nearest smart>;
enum SubpixelHinting is export <rgb bgr vrgb vbgr none>;
enum BackgroundMode is export <stretch fill fit center tile>;

has $!sway is built;

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
has ScaleFilter $.scale-filter;
has Str $.serial;
has Bool $.sticky;
has SubpixelHinting $.subpixel-hinting;
has Str $.transform;
has Str $.type;
has Bool $.urgent;
has $.window;
has OutputRect $.window-rect;


multi method resolution(OutputMode $resolution, Bool :$custom is copy) returns Bool {
  $custom //= $resolution ∉ @!modes;
  warn "Custom are disabled, but resolution doesn't in allowed list"
    if not $custom and $resolution ∉ @!modes;
  [&&] $!sway.run: "output $!name resolution {$custom ?? '--custom' !! ''} $resolution";
}

multi method resolution(Int :$width, Int :$height, :$rate, Bool :$custom) returns Bool {
  if $rate.defined {
    self.resolution: OutputMode.new(:$width, :$height, refresh=>$rate*1000), :$custom;
  } else {
    self.resolution: OutputMode.new(:$width, :$height), :$custom;
  }
}

multi method resolution(Int $width, Int $height, $rate?, Bool :$custom) returns Bool {
  self.resolution: :$width, :$height, :$rate, :$custom;
}


multi method position(OutputRect $position) returns Bool {
  [&&] $!sway.run: "output $!name position $position";
}
multi method position(Int :$x!, Int :$y!, Int :$width, Int :$height) returns Bool {
  self.position: OutputRect.new: :$x, :$y, :$width, :$height;
}
multi method position(Int $x, Int $y, Int $width?, Int $height?) returns Bool {
  self.position: :$x, :$y, :$width, :$height;
}

multi method scale(Rat() $scale) returns Bool {
  [&&] $!sway.run: "output $!name scale $scale";
}
multi method scale returns Rat {
  $!scale;
}

multi method scale-filter(ScaleFilter $filter) returns Bool {
  [&&] $!sway.run: "output $!name scale_filter $filter";
}
multi method scale-filter(Str $filter) returns Bool {
  self.scale-filter: ScaleFilter::{$filter};
}
multi method scale-filter returns ScaleFilter {
  $!scale-filter
}

multi method subpixel(SubpixelHinting $subpixel) returns Bool {
  [&&] $!sway.run: "output $!name subpixel $subpixel";
}
multi method subpixel(Str $subpixel) returns Bool {
  self.subpixel: SubpixelHinting::{$subpixel};
}

multi method background(Str $file where *.IO.e, BackgroundMode $mode, Color $color?) returns Bool {
  [&&] $!sway.run: "output $!name background $file $mode {$color // ''}";
}
multi method background(Str $file where *.IO.e, BackgroundMode $mode, $color) returns Bool {
  self.background: $file, $mode, Color.new: $color;
}
multi method background(Color $color) returns Bool {
  [&&] $!sway.run: "output $!name background $color solid_color";
}
multi method background($color) returns Bool {
  self.background: Color.new: $color;
}

multi method transform {
  if ?%_ {
    self.transform: 0, |%_;
  } else {
    $!transform;
  }
}
multi method transform(
  Int $transform where 0|90|180|270,
  Bool :$flip = False,
  Bool :$clockwise,
) returns Bool {
  my Str $clk = $clockwise.defined ?? ($clockwise ?? 'clockwise' !! 'anticlockwise') !! '';
  my Str $tr;
  $tr = 'flipped' if $flip;
  $tr ~= '-' ~ $transform if $flip && $transform ≠ 0;
  $tr ~= $transform unless $flip;

  [&&] $!sway.run: "output $!name transform $tr $clk";
}

method enable returns Bool {
  [&&] $!sway.run: "output $!name enable";
}
method disable returns Bool {
  [&&] $!sway.run: "output $!name disable";
}
method toggle returns Bool {
  [&&] $!sway.run: "output $!name toggle";
}

multi method dpms returns Bool {
  $!dpms;
}
multi method dpms(Bool $status) returns Bool {
  [&&] $!sway.run: "output $!name dpms {$status ?? 'on' !! 'off'}";
}

multi method max-render-time {
  $!max-render-time;
}
multi method max-render-time(Bool $ where *.not) {
  [&&] $!sway.run: "output $!name max_render_time off";
}
multi method max-render-time(Int $ms) {
  [&&] $!sway.run: "output $!name max_render_time $ms";
}

multi method adaptive-sync returns Bool {
  $!adaptive-sync;
}
multi method adaptive-sync(Bool $status) returns Bool {
  [&&] $!sway.run: "output $!name adaptive_sync {$status ?? 'on' !! 'off'}";
}

method new {
  if %_<adaptive_sync_status>:exists {
    %_<adaptive-sync> = %_<adaptive_sync_status> ne 'disabled';
    die "adaptive_sync_status value unknown" unless %_<adaptive_sync_status> eq 'disabled' | 'enabled';
    %_<adaptive_sync_status>:delete;
  }

  for <current-border-width current-mode current-workspace 
  deco-rect floating-nodes fullscreen-mode scale-filter subpixel-hinting window-rect> {
    if %_{S:g/"-"/_/}:exists {
      %_{$_} = %_{S:g/"-"/_/};
      %_{S:g/"-"/_/}:delete;
    }
  }

  %_<current-mode>     = OutputMode.new: |%_<current-mode>         if %_<current-mode>:exists;
  my OutputMode @modes = @(%_<modes>.map({OutputMode.new: |%$_}));
  #%_<modes>            = @modes;
  %_<deco-rect>        = OutputRect.new: |%_<deco-rect>            if %_<deco-rect>:exists;
  %_<geometry>         = OutputRect.new: |%_<geometry>             if %_<geometry>:exists;
  %_<rect>             = OutputRect.new: |%_<rect>;
  %_<window-rect>      = OutputRect.new: |%_<window-rect>          if %_<window-rect>:exists;
  %_<scale-filter>     = ScaleFilter::{%_<scale-filter>}           if %_<scale-filter>:exists;
  %_<subpixel-hinting> = SubpixelHinting::{%_<subpixel-hinting>}   if %_<subpixel-hinting>:exists;

  %_<current-workspace>:delete unless %_<current-workspace>.defined;

  return self.bless: |%_, :@modes;
}
