# lita-team-cymru

This gem gives Lita the ability to query various data endpoints exposed
by the folks at [Team Cymru](www.team-cymru.org).

Currently, the following features are supported:

* [IP to ASN Mapping](http://www.team-cymru.org/IP-ASN-mapping.html)
* [AS information lookup](http://www.team-cymru.org/IP-ASN-mapping.html)
* [Bogon lookup via DNS](http://www.team-cymru.org/bogon-reference-dns.html)

## Installation

Add lita-team-cymru to your Lita instance's Gemfile:

```
gem "lita-team-cymru"
```

## Configuration

This gem requires no configuration.

## Usage

Map IP address to BGP origin:

```
< you> lita: cymru 192.5.5.241
< lita> AS      | IP               | BGP Prefix          | AS Name
< lita> 3557    | 192.5.5.241      | 192.5.5.0/24        | ISC-AS - Internet Systems Consortium, Inc., US
```

Map IPv6 address to BGP origin:

```
< you> lita: cymru 2001:500:2f::f
< lita> AS      | IP                                       | BGP Prefix          | AS Name
< lita> 3557    | 2001:500:2f::f                           | 2001:500:2f::/48    | ISC-AS - Internet Systems Consortium, Inc., US
```

Get AS information:

```
< you> lita: cymru as3557
< lita> AS Name
< lita> ISC-AS - Internet Systems Consortium, Inc., US
```

Check if a given IP address is a bogon:

```
< you> lita: cymru bogon 10.10.10.10
< lita> bogon in 10.0.0.0/8
```

```
< you> lita: cymru bogon 2a02:4a08::23
< lita> bogon in 2a02:4a08::/29
```

```
< you> lita: cymru bogon 8.8.8.8
< lita> not a bogon
```
