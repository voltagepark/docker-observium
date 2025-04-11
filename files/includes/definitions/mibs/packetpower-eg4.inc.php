<?php
/**
 * Observium
 *
 *   This file extended from the base of Observium.
 *
 */

$mib = 'PACKETPOWER-EG4-MIB';
$config['mibs'][$mib]['enable'] = 1;
$config['mibs'][$mib]['mib_dir'] = 'voltagepark';
$config['mibs'][$mib]['identity_num'] = '.1.3.6.1.4.1.33688';
$config['mibs'][$mib]['descr'] = 'Packet Power Node MIB';

// EOF