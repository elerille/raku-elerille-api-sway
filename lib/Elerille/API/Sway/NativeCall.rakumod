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

unit module Elerille::API::Sway::NativeCall;

use NativeCall;

constant PF_LOCAL is export = 1;
constant SOCK_STREAM is export = 1;
constant F_SETFD is export = 2;
constant FD_CLOEXEC is export = 1;

sub socket(
  int32 $domain, 
  int32 $type, 
  int32 $protocol
) returns int32 is native is export {*}

sub fcntl(
  int32 $fd,
  int32 $cmd,
  int32 $arg
) returns int32 is native is export {*}

sub connect(
  int32 $sockfd,
  buf8 $sockaddr,
  size_t $addrlen
) returns int32 is native is export {*}

sub close(
  int32 $fd
) returns int32 is native is export {*}

sub write(
  int32 $fd,
  buf8 $buf,
  size_t $count
) returns ssize_t is native is export {*}

sub read(
  int32 $fd,
  buf8 $buf is rw,
  size_t $count
) returns ssize_t is native is export {*}
