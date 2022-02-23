set -l compose_command compose
set -l compose_up_command up

complete -c docker -a compose -d "Docker Compose V2"

for line in (docker compose --help | string match -r '^\s+\w+\s+[^\n]+' | string trim)
  set -l doc (string split -m 1 ' ' -- $line)
  complete -c docker -n '__fish_seen_subcommand_from $compose_command' -xa $doc[1] --description $doc[2]
end

complete -c docker -n '__fish_seen_subcommand_from $compose_command' -s h -l help                   -d 'Print usage'
complete -c docker -n '__fish_seen_subcommand_from $compose_command' -l ansi -a 'never always auto' -d 'Control when to print ANSI control characters'
complete -c docker -n '__fish_seen_subcommand_from $compose_command' -l --compatibility             -d 'Run compose in backward compatibility mode'
complete -c docker -n '__fish_seen_subcommand_from $compose_command' -l env-file -r                 -d 'Specify an alternate environment file'
complete -c docker -n '__fish_seen_subcommand_from $compose_command' -s f -l file -r                -d 'Specify an alternate compose file'
complete -c docker -n '__fish_seen_subcommand_from $compose_command' -l profile -r                  -d 'Specify a profile to enable'
complete -c docker -n '__fish_seen_subcommand_from $compose_command' -l project-directory -r	    -d 'Specify an alternate working directory'
complete -c docker -n '__fish_seen_subcommand_from $compose_command' -s p -l project-name -x        -d 'Specify an alternate project name'

complete -c docker -n '__fish_seen_subcommand_from $compose_command; and __fish_seen_subcommand_from $compose_up_command' -l force-recreate -d 'Recreate containers even if their configuration and image haven\'t changed'
