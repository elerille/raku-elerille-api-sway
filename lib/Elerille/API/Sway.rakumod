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

use Elerille::API::Sway::NativeCall;
use NativeCall;
use JSON::Fast;

constant SWAY-IPC-MAGIC = "i3-ipc";

has $.socket-path is built = %*ENV<SWAYSOCK>;
has $!socket;

has %!channel = {
  0 => Channel.new,
  1 => Channel.new,
  2 => Channel.new,
  3 => Channel.new,
  4 => Channel.new,
  5 => Channel.new,
  6 => Channel.new,
  7 => Channel.new,
  8 => Channel.new,
  9 => Channel.new,
  10 => Channel.new,
  11 => Channel.new,
  12 => Channel.new,
  100 => Channel.new,
  101 => Channel.new,
};
has %!supplier = {
  0x80000000 => Supplier.new,
  0x80000002 => Supplier.new,
  0x80000003 => Supplier.new,
  0x80000004 => Supplier.new,
  0x80000005 => Supplier.new,
  0x80000006 => Supplier.new,
  0x80000007 => Supplier.new,
  0x80000014 => Supplier.new,
  0x80000015 => Supplier.new,
};

#| Sent whenever a change involving a workspace occurs. 
method event-workspace returns Supply {
  %!supplier{0x80000000}.Supply;
}

#| Sent whenever the binding mode changes.
method event-mode returns Supply {
  %!supplier{0x80000002}.Supply;
}

#| Sent whenever a change involving a view occurs.
method event-window returns Supply {
  %!supplier{0x80000003}.Supply;
}

#| Sent whenever a config for a bar changes.
method event-barconfig-update returns Supply {
  %!supplier{0x80000004}.Supply;
}

#| Sent whenever a binding is executed.
method event-binding returns Supply {
  %!supplier{0x80000005}.Supply;
}

#| Sent whenever the IPC is shutting down.
method event-shutdown returns Supply {
  %!supplier{0x80000006}.Supply;
}

#| Sent when first subscribing to tick events or by a SEND_TICK message.
method event-tick returns Supply {
  %!supplier{0x80000007}.Supply;
}

#| Sent when the visibility of a bar changes due to a modifier being pressed.
method event-bar-state-update returns Supply {
  %!supplier{0x80000014}.Supply;
}

#| Sent when something related to the input devices changes.
method event-input returns Supply {
  %!supplier{0x80000015}.Supply;
}

#| Parses and runs the payload as sway commands
method run(Str $command) {
  self!send-msg(0, $command);
  start {
    %!channel{0}.receive;
  }
}

#| Retrieves the list of workspaces.
method get-workspaces {
  self!send-msg(1);
  start {
    %!channel{1}.receive;
  }
}

#| Subscribe this IPC connection to the event types specified in the message payload.
method subscribe(*@events) {
  self!send-msg(2, to-json @events);
  start {
    %!channel{2}.receive;
  }
}

#| Retrieve the list of outputs
method get-outputs {
  self!send-msg(3);
  start {
    %!channel{3}.receive;
  }
}

#| Retrieve a JSON representation of the tree
method get-tree {
  self!send-msg(4);
  start {
    %!channel{4}.receive;
  }
}

#| Retrieve the currently set marks
method get-marks {
  self!send-msg(5);
  start {
    %!channel{5}.receive;
  }
}

#| Retrieves the list of configured bar IDs
multi method get-bars {
  self!send-msg(6);
  start {
    %!channel{6}.receive;
  }
}

#| Retrieves the list of configured bar IDs
multi method get-bar-config(Str $bar-id) {
  self!send-msg(6, $bar-id);
  start {
    %!channel{6}.receive;
  }
}

#| Retrieve version information about the sway process
multi method get-version {
  self!send-msg(7);
  start {
    %!channel{7}.receive;
  }
}

#| Retrieve the list of binding modes that currently configured
multi method get-binding-modes {
  self!send-msg(8);
  start {
    %!channel{8}.receive;
  }
}

#| Retrieve the contents of the config that was last loaded
multi method get-config {
  self!send-msg(9);
  start {
    %!channel{9}.receive;
  }
}

#| Issues a TICK event to all clients subscribing to the event 
#| to ensure that all events prior to the tick were received.
#| If a payload is given, it will be included in the TICK event
multi method send-tick(Str $payload = "") {
  self!send-msg(10, $payload);
  start {
    %!channel{10}.receive;
  }
}

#| For i3 compatibility, this command will just return a failure
#| object since it does not make sense to implement in sway due
#| to the X11 nature of the command.  If you are curious about
#| what this IPC command does in i3, refer to the i3 documentation.
multi method sync() {
  self!send-msg(11);
  start {
    %!channel{11}.receive;
  }
}

#| Returns the currently active binding mode.
multi method get-binding-state() {
  self!send-msg(12);
  start {
    %!channel{12}.receive;
  }
}

#| Retrieve a list of the input devices currently available
multi method get-inputs() {
  self!send-msg(100);
  start {
    %!channel{100}.receive;
  }
}

#| Retrieve a list of the seats currently configured
multi method get-seats() {
  self!send-msg(101);
  start {
    %!channel{101}.receive;
  }
}

method TWEAK {
  $!socket = socket PF_LOCAL, SOCK_STREAM, 0;
  die "Could not create socket" if $!socket == -1;

  fcntl $!socket, F_SETFD, FD_CLOEXEC;

  my $size = 2 + 108;

  my buf8 $buf .= new;
  $buf.write-uint16(0, PF_LOCAL);
  $buf.append($!socket-path.encode);
  $buf.reallocate($size);

  my $ret = connect $!socket, $buf, $size;
  die "Could not connect to Sway" if $ret < 0;
  start {
    loop {
      self!read-msg;
    }
  }
  return;
}

submethod DESTROY {
  close $!socket;
}

method !send-msg(int32 $type, Str $payload="") {
  my buf8 $msg .= new;
  $msg.append(SWAY-IPC-MAGIC.encode);
  $msg.write-uint32($msg.elems, $payload.encode.elems);
  $msg.write-uint32($msg.elems, $type);
  $msg.append($payload.encode);

  my $written = 0;
  while $written < $msg.elems {
    my $n = write $!socket, $msg.subbuf($written), $msg.elems - $written;
    die "[C] write() failed" if $n == -1;
    $written += $n;
  }
}

method !read-msg returns Str {
  my $header-size = SWAY-IPC-MAGIC.encode.elems + nativesizeof(uint32)*2;
  my buf8 $header = self!read-size($header-size);
  die "Wrong magic code"
    unless $header.subbuf(0, SWAY-IPC-MAGIC.encode.elems).decode eq SWAY-IPC-MAGIC;
  my $size = $header.read-uint32(SWAY-IPC-MAGIC.encode.elems);
  my $type = $header.read-uint32(SWAY-IPC-MAGIC.encode.elems + nativesizeof uint32);
  my buf8 $msg = self!read-size($size);
  #say "RCV: ", $msg.decode;
  if %!channel{$type}:exists {
    %!channel{$type}.send(from-json $msg.decode);
  }
  if %!supplier{$type}:exists {
    %!supplier{$type}.emit(from-json $msg.decode);
  }
  return $msg.decode;
}

method !read-size(Int $size) returns buf8 {
  my buf8 $msg .= new;
  my Int $rec = 0;
  while $rec < $size {
    my buf8 $tmpbuf .= new;
    $tmpbuf.reallocate($size - $rec);
    my $n = read $!socket, $tmpbuf, $size - $rec;
    die "[C] read() failed" if $n == -1;
    die "EOF" if $n == 0;
    $msg.append: $tmpbuf.subbuf(0,$n);
    $rec += $n;
  }
  return $msg;
}
