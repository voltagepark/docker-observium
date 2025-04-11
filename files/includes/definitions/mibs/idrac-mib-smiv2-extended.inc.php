<?php
/**
 * Observium
 *
 *   This file was used to extend iDRAC from base observium
 *
 */

$mib = 'IDRAC-MIB-SMIv2';
$config['mibs'][$mib]['enable'] = 1;
$config['mibs'][$mib]['identity_num'] = '.1.3.6.1.4.1.674.10892.5';
$config['mibs'][$mib]['mib_dir'] = 'dell';
$config['mibs'][$mib]['descr'] = 'Dell iDRAC v7 and newer devices Extended';

// Processor Object Status
$config['mibs'][$mib]['status'][] = [
    'table'               => 'processorDeviceTable',
    'oid'                 => 'processorDeviceStatus',
    'oid_descr'           => 'processorDeviceFQDD',
    'descr_transform'     => [ 'action' => 'replace', 'from' => [ '.' ], 'to' => [ ' ' ] ],
    'measured'            => 'processor',
    'oid_num'             => '.1.3.6.1.4.1.674.10892.5.4.1100.30.1.5',
    'type'                => 'ObjectStatusEnum',
];

// Memory Object Status
$config['mibs'][$mib]['status'][] = [
    'table'               => 'memoryDeviceTable',
    'oid'                 => 'memoryDeviceStatus',
    'oid_descr'           => 'memoryDeviceLocationName',
    'descr_transform'     => [ 'action' => 'replace', 'from' => [ '.' ], 'to' => [ ' ' ] ],
    'measured'            => 'memory',
    'oid_num'             => '.1.3.6.1.4.1.674.10892.5.4.1100.50.1.5',
    'type'                => 'ObjectStatusEnum',
];

// GPU Object Status
$config['mibs'][$mib]['status'][] = [
    'table'               => 'pCIDeviceTableEntry',
    'oid'                 => 'pCIDeviceStatus',
    'oid_descr'           => 'pCIDeviceFQDD',
    'descr_transform'     => [ 'action' => 'replace', 'from' => [ 'Video.Slot.', '-1' ], 'to' => [ 'System Board GPU', '' ] ],
    'measured'            => 'gpu',
    'oid_num'             => '.1.3.6.1.4.1.674.10892.5.4.1100.80.1.5',
    'type'                => 'ObjectStatusEnum',
    'test'                => [ 'field' => 'pCIDeviceFQDD', 'operator' => 'regex', 'value' => '^Video\.Slot' ],
];

// Network InfiniBand Object Status
$config['mibs'][$mib]['status'][] = [
    'table'               => 'pCIDeviceTableEntry',
    'oid'                 => 'pCIDeviceStatus',
    'oid_descr'           => 'pCIDeviceFQDD',
    'descr_transform'     => [ 'action' => 'replace', 'from' => [ '.', '-1' ], 'to' => [ ' ', '' ] ],
    'measured'            => 'network',
    'oid_num'             => '.1.3.6.1.4.1.674.10892.5.4.1100.80.1.5',
    'type'                => 'ObjectStatusEnum',
    'test'                => [ 'field' => 'pCIDeviceFQDD', 'operator' => 'regex', 'value' => '^InfiniBand\.Slot\.' ],
];

// Network Object Status
$config['mibs'][$mib]['status'][] = [
    'table'               => 'networkDeviceTableEntry',
    'oid'                 => 'networkDeviceStatus',
    'oid_descr'           => 'networkDeviceFQDD',
    'descr_transform'     => [ 'action' => 'replace', 'from' => [ '.', '-1-1', '-2-1' ], 'to' => [ ' ', '', '' ] ],
    'measured'            => 'network',
    'oid_num'             => '.1.3.6.1.4.1.674.10892.5.4.1100.90.1.3',
    'type'                => 'ObjectStatusEnum',
];

// EOF