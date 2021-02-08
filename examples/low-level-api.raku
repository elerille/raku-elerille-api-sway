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
use JSON::Fast;

my Sway $sway .= new;
say $sway.subscribe(
  "workspace",
  "mode",
  "window",
  "barconfig_update",
  "binding",
  "shutdown",
  "tick",
  "bar_state_update",
  "input",
).result;
say $sway.run("exec echo bonjour").result;
say $sway.get-workspaces.result;
say $sway.get-outputs.result;
say $sway.get-tree.result;
say $sway.get-marks.result;
say $sway.get-bars.result;
say $sway.get-bar-config("bar-0").result;
say $sway.get-version.result;
say $sway.get-binding-modes.result;
say $sway.get-config.result<config>;
say $sway.send-tick.result;
say $sway.send-tick("Bonjour").result;
say $sway.sync.result;
say $sway.get-binding-state.result;
say $sway.get-inputs.result;
say $sway.get-seats.result;

react {
  whenever $sway.event-workspace -> $v {
    say "RCV workspace";
  }
  whenever $sway.event-mode -> $v {
    say "RCV mode";
  }
  whenever $sway.event-window -> $v {
    say "RCV window";
  }
  whenever $sway.event-barconfig-update -> $v {
    say "RCV barconfig-update";
  }
  whenever $sway.event-binding -> $v {
    say "RCV binding";
  }
  whenever $sway.event-shutdown -> $v {
    say "RCV shutdown";
  }
  whenever $sway.event-tick -> $v {
    say "RCV tick ", $v;
  }
  whenever $sway.event-bar-state-update -> $v {
    say "RCV bar-state-update ", $v;
  }
  whenever $sway.event-input -> $v {
    say "RCV input";
  }
}


