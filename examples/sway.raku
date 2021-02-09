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


my Sway $sway .= new;

$sway.run: "exec", "echo", "bonjour";

for $sway.output -> $output {
  say "Output {$output.name} {$output.make} {$output.model} {$output.serial}";
  say "  Focus: {$output.focused}";
  say "  Current mode: {$output.current-mode}";
  say "  Position: {$output.rect}";
  say "  Scale factor: {$output.scale}";
  say "  Scale filter: {$output.scale-filter}";
  say "  Subpixel hinting: {$output.subpixel-hinting}";
  say "  Transform: {$output.transform}";
  say "  Workspace: {$output.current-workspace}";
  say "  Max render time: {$output.max-render-time.gist}";
  say "  Adaptive sync: {$output.adaptive-sync}";
  say "  Available modes:";
  say $output.modes.join("\n").indent(4);
  say "";
}

