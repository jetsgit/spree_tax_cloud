Spree TaxCloud SOAP API 
=======================

USA Tax calculation extension for Spree using Tax Cloud service .

Based on the work of Chris Mar and Drew Tempelmeyer.

USAGE
-----

Create an account with TaxCloud:

    https://taxcloud.net

...and get an api_login_id and api_key.

Run below to install migrations:

    bundle exec rails g spree_tax_cloud:install

Configure in Spree Admin
------------------------

Go to configurations, then on left side of page
will be a link for TaxCloud settings. Enter your
login, api_id, product tic, shipping tic, and business address.

NOTE
----

Capture and authorize are performed in 'capture'.

Verify address is implemented for Spree 2+.

TODO
----

Request spec to ensure integration works throughout checkout process.
Lookup tax per shipment in order to properly lookup tax from actual stock location rather than the default.

COPYRIGHT
---------

[Copyright]( http://jet.mit-license.org/ ) by Jerrold R Thompson 
