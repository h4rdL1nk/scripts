BEGIN{
    print "Script start";
}

{
    match($0,/[A-Z0-9]{10,12}/);
    id_conn=substr($0,RSTART,RLENGTH);
    #ids[id_conn];
}

/postfix\/smtpd\[[0-9]+\]: [A-Z0-9]+: client=/{
    match($0,/client=.*/);
    orig=substr($0,RSTART+7,RLENGTH-7);
    #ids_in[id_conn];
    ids[id_conn];
    ids_type[id_conn]="inbound";
    ids_orig[id_conn]=orig;
}

/postfix\/submission\/smtpd\[[0-9]+\]: [A-Z0-9]+: client=/{
    match($0,/client=.*/);
    orig=substr($0,RSTART+7,RLENGTH-7);
    #ids_out[id_conn];
    ids[id_conn];
    ids_type[id_conn]="outbound";
    ids_orig[id_conn]=orig;
}

/postfix\/qmgr\[[0-9]+\]: [A-Z0-9]+: from=/{
    match($0,/from=<(.*)>/);
    split(substr($0,RSTART,RLENGTH),a,"<");
    split(a[2],b,">");
    from=b[1];
    ids_from[id_conn]=from;
}

/postfix\/pipe\[[0-9]+\]: [A-Z0-9]+: to=/{
    match($0,/to=<(.*)>/);
    split(substr($0,RSTART,RLENGTH),a,"<");
    split(a[2],b,">");
    to=b[1];
    ids_to[id_conn]=to;

    match($0,/status=[a-z]+/);
    split(substr($0,RSTART,RLENGTH),c,"=");
    status=c[2];
    ids_status[id_conn]=status;

    time=$1" "$2" "$3
    ids_time[id_conn]=time
}

/postfix\/smtp\[[0-9]+\]: [A-Z0-9]+: to=/{
    match($0,/to=<(.*)>/);
    split(substr($0,RSTART,RLENGTH),a,"<");
    split(a[2],b,">");
    to=b[1];
    ids_to[id_conn]=to;

    match($0,/status=[a-z]+/);
    split(substr($0,RSTART,RLENGTH),c,"=");
    status=c[2];
    ids_status[id_conn]=status;

    time=$1" "$2" "$3
    ids_time[id_conn]=time
}
    
END{
    for(id in ids){
        print id" - "ids_type[id]" - "ids_time[id]" - "ids_orig[id]" - "ids_from[id]" -> "ids_to[id]" ["ids_status[id]"]";
    }
}