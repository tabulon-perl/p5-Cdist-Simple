#!/bin/sh

# ATTENTION: This file is meant to be sourced from a POSIX compatible shell
# Don't mind the shebang! Executing this as a script should have no effect.

# PRIVATE logging routines
_csl_eprintf() { 1>&2 printf '%s: ' "$(basename "$0")";  1>&2 printf "$@" ;}
_csl_DEBUG()   { _csl_eprintf "$@"  ;}
_csl_INFO()    { _csl_eprintf "$@"  ;}
_csl_ERROR()   { _csl_eprintf "$@"  ;}
_csl_FATAL()   { _csl_eprintf "$@"  ;}

# UTILITY routines
_uc()           { echo "$*" | tr '[:lower:]' '[:upper:]' ;}
_lc()           { echo "$*" | tr '[:upper:]' '[:lower:]' ;}

# PUBLIC synonyms
item()          { cdist_item "$@" ;}
ensure()        { cdist_ensure "$@" ;}

# PUBLIC routines
cdist_item()    {
  # cdist_item() prints out the fully qualified cdist type/object-id, which may come handy for declaring dependencies
  cdist_ensure "$@" 5>&1 1>/dev/null
}

cdist_ensure()  {
  # File descriptors 4 and 5 are our alternate IN/OUT channels (by our own convention), that we call ALTIN/ALTOUT.
  # We use them so that STDIN/STDOUT (untouched by us) can be used  by the invoked commands (cdist types)
  # If they aren't available for reading/writing, we just use /dev/null

  { true <&4   ;} 1>/dev/null 2>&1  || exec 4</dev/null   # if fd#4 (ALTIN)  is not available, open /dev/null for reading
  { true >&5   ;} 1>/dev/null 2>&1  || exec 5>/dev/null   # if fd#5 (ALTOUT) is not available, open /dev/null for writing

  local state cmd req strict; state= ; cmd= ; req=; strict=
  local ropt mopt marg arg; arg=
  local skip skip_next beyond meat; beyond=

  # For this sort of argument processing (without getopt[s]),
  # see: [shell - How to remove a positional parameter from $@ - Stack Exchange](https://unix.stackexchange.com/a/258514)
  for arg in "$@" ; do
    shift

    if [ -n "$skip_next" ] ; then
      skip_next=
      continue
    fi

    ropt= ; mopt= ; marg= ; skip=
    case "$arg" in
      --*)
            meat="$( echo "$arg" | cut -c3- )" ## get rid of the leading '--'
            IFS=':' read ropt mopt marg <<< "$meat"
            mopt="$(_lc "$mopt")"
            case "$mopt" in
              strict) strict=1
                      ;;
              require|required|requires)
                      req+="${marg:+"${marg}/"}${1}"$'\n'
                      skip_next=1
                      ;;
              absent|present|installed|removed|disabled|enabled|exists|pre-exists|running|started|stopped)
                      state="$( echo "$mopt" | cut -c3- )" ## get rid of the leading '--'
                      ;;
              state)  $marg="$( _lc "$marg" )";
                      if [ -n "$marg" ] ; then
                        state="$marg"
                      else
                        state="$1"
                        skip_next=1
                      fi
                      ;;
            esac
            [ -z "$ropt" ] && skip=1  || arg="--${ropt}"
            ;;
      --)   ;; # Usually means "end of options", but we don't do anything special with it ==> pass-thru
      -*)   ;; # single letter option ==> Pass-thru
      *)    [ -n "$cmd" ] || { cmd="$arg"; skip=1 ;}  ;;
    esac

    if [ -z "$skip" ] ; then
      set -- "$@" "$arg"
    fi
  done

  # Slurp any eventual dependencies passed in via ALTIN (file descriptor 4).
  req+="$(cat <&4)"

  # Append newly collected dependencies to $require (and tidy up)
  if [ -n "$req" ] ; then
    [ -z "$require" ] || require+=$'\n'
    require+="$req"
    require="$(echo "$require" | tr '\n' ' ' | tr -s ' ')"
  fi

  # Determine the command name (typically a shim for a cdist type)
  if    [ -z "$strict" ] && \
      ! { echo "$cmd" | grep -q '/' ;} && \
      ! [ '__' == "$(echo "$cmd" | cut -c1-2)" ]; then
    cmd="__${cmd}"    # By convention, cdist type names start with double underscores (__)
  fi

  # figure out and print the fully qualified cdist type/object-id on an alternate output stream
  # This may come handy for declaring dependencies. See: item()
  local id ; id="$cmd"
  [ -z "$1" ] || [ '--' == "$( echo "$1" | cut -c1-2 )" ] || id+="/$1"
  1>&5 echo "${id}"

  # _csl_INFO 'state    : %s\n' "$state"
  # _csl_INFO 'require  : %s\n' "$require"
  # _csl_INFO 'id       : %s\n' "$id"
  # _csl_INFO 'cmd      : %s\n'  "$(echo "$cmd" "$@")"

  # Invoke the requested command (typically a shim standing for a cdist type),
  # -- respecting the cdist API for declaring dependencies (using the environment variable '$require')
  if { ! command -v "$cmd" 1>/dev/null 2>&1 ;} ; then
    _csl_FATAL "Command not found: '$cmd'\n"; exit 1;
  fi
  require="$require" $cmd "$@"
}
