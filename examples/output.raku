#!/usr/bin/raku
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

use lib 'lib';

use Elerille::API::Sway;

# need for enum access, but you can also use Str value
use Elerille::API::Sway::Output;

my Sway $sway .= new;

$sway.run: "exec", "echo", "bonjour";

# Show information about all screen
for $sway.output -> $output {
  say "Output {$output.name} {$output.make} {$output.model} {$output.serial}";
  say "  Focus: {$output.focused}" if $output.focused.defined;
  say "  Current mode: {$output.current-mode}" if $output.current-mode.defined;
  say "  Position: {$output.rect}" if $output.rect.defined;
  say "  Scale factor: {$output.scale}" if $output.scale.defined;
  say "  Scale filter: {$output.scale-filter}" if $output.scale-filter.defined;
  say "  Subpixel hinting: {$output.subpixel-hinting}" if $output.subpixel-hinting.defined;
  say "  Transform: {$output.transform}" if $output.transform.defined;
  say "  Workspace: {$output.current-workspace}" if $output.current-workspace.defined;
  say "  Max render time: {$output.max-render-time}" if $output.max-render-time.defined;
  say "  Adaptive sync: {$output.adaptive-sync}" if $output.adaptive-sync.defined;
  say "  Available modes:";
  say $output.modes.join("\n").indent(4);
  say "";
}

my $output1 = $sway.output[0];
my $output = $sway.output[1];

# Change resolution of an output
$output.resolution: $output.modes[*-1];
#$output.resolution: 100, 100;
#$output.resolution: $output.modes[*-1], :custom;
#$output.resolution: $output.modes[*-1], :!custom;
#$output.resolution: 100, 100, :custom;
#$output.resolution: 100, 100, :!custom;

# Change the position of the screen
#$output.position: $output.rect;
$output.position: 0, 0;
$output1.position: 1920, 0;

# Change the scale of the screen
$output.scale: $output.scale // 1;

# Change the scale_filter
$output.scale-filter: nearest;
$output.scale-filter: "nearest";
#$output.scale-filter: linear;
#$output.scale-filter: smart;


$output.subpixel: rgb;
$output.subpixel: "rgb";

# Change the background
{
  my $file = "$*HOME/.backgrounds/2014-06-14_pepper_first-artwork_by-David-Revoy.jpg";
  $output.background: $file, fit;
  $output.background: $file, fit, "#f0f";
  $output.background: "#005";
}

# Change the screen orientation
#$output.transform: 90, :clockwise;
$output.transform: 0;
#$output.transform: :flip;
#$output.transform: :flip, :clockwise;
#$output.transform: :flip, :!clockwise;


# Enable/Disable output
#$output.enable;
#$output.disable;
#$output.toggle;

# Enable/Disable dpms
#$output.dpms: False;
$output.dpms: True;

# Change max_render_time
#$output.max-render-time: False;
#$output.max-render-time: 1;

# Change adaptive_sync
#$output.adaptive-sync: True;
#$output.adaptive-sync: False;

