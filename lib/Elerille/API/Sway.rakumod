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

unit class Elerille::API::Sway is export;

use Elerille::API::Sway::LowLevel;

use Elerille::API::Sway::Output;

has Elerille::API::Sway::LowLevel $!sway;

method BUILD(:$socket-path) {
  if $socket-path.defined {
    $!sway .= new: :$socket-path;
  } else {
    $!sway .= new;
  }
}

method run(*@command) {
  say "> ", @command.join(' ');
  $!sway.run: @command.join(' ')
  ==> await()
  ==> map({ warn $_.gist unless .<success>; .<success> })
}

multi method output {
  $!sway.get-outputs
  ==> await()
  ==> map({ Output.new(sway=>self, |$_) })
}

multi method output(Str $name) returns Output {
  self.output.grep({ .name eq $name })[0]
}





