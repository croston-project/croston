#!/usr/bin/env bash
# Copyright (c) 2016-2019 The Bitcoin Core Developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

BITCOIND=${BITCOIND:-$BINDIR/crostond}
BITCOINCLI=${BITCOINCLI:-$BINDIR/croston-cli}
BITCOINTX=${BITCOINTX:-$BINDIR/croston-tx}
WALLET_TOOL=${WALLET_TOOL:-$BINDIR/croston-wallet}
BITCOINQT=${BITCOINQT:-$BINDIR/qt/croston-qt}

[ ! -x $BITCOIND ] && echo "$BITCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
read -r -a CROSVER <<< "$($BITCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }')"

# Create a footer file with copyright content.
# This gets autodetected fine for crostond if --version-string is not set,
# but has different outcomes for croston-qt and croston-cli.
echo "[COPYRIGHT]" > footer.h2m
$BITCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $BITCOIND $BITCOINCLI $BITCOINTX $WALLET_TOOL $BITCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${CROSVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${CROSVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
