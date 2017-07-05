[Unit]
Description=Anycast interface (${name})
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ip link add dummy-${name} type dummy
${addresses}
ExecStart=/sbin/ip link set dev dummy-${name} up
ExecStop=/sbin/ip link del dummy-${name} type dummy
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
