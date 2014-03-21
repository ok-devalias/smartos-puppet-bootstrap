# Persistent .bashrc


# Function allowing for use of <alias> in place of <uuid> when alias is unique
function vmadm() {
        local op="$1"; shift
        local uuid="$1"; shift
 
        local r='^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}$'
        local skip=(create list lookup receive help)
 
        # These options don't take a uuid argument
        if [[ ! ${skip[*]} =~ $op ]]; then
                # If a uuid was passed, then do nothing
                if [[ ! "$uuid" =~ $r ]]; then
                        uuid=$(command vmadm lookup -1 alias=$uuid)
                        if [[ ! -n "$uuid" ]]; then
                                echo "Alias $uuid not found."
                        fi
                fi
        fi
        command vmadm $op $uuid $@
}
