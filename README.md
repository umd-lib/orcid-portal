# orcid-portal

Rails application for associating ORCID identifiers to university members.

## Introduction

This application enables a UMD student/staff/faculty member to associate
an ORCID id with a university-specific identifier.

This application uses information provided by a CAS login to retrieve the
university-specific identifier, so a CAS login is immediately shown when
accessing the application.

Since ORCID ids are supposed to be unique, each user is only allowed to
associate one ORCID id with their university identifier. If a user's ORCID id
is already known to the application, the user is immediately shown a page with
their ORCID id and the date it was registered.

Users that are not registered are redirected to the ORCID website, which
requires them to log in. After successfully logging in and allowing the
application to access their ORCID id, the application associates the
university identifier with the ORCID id. See the "ORCID API Workflow" section
for additional details on how the ORCID API works.

## ORCID API Workflow

This application follows the steps in the
[Basic tutorial: Get an authenticated ORCID iD][1]:

1) Redirects the browser to the ORCID website to request an authorization code,
   providing a callback address.

2) At the ORCID website, the user logs in, and authorizes the application to
   access the ORCID id. ORCID then redirects the browser to the callback URL,
   with an authorization code.

3) When the callback URL is called, the authorization code is used to retrieve
   the ORCID id, which is then stored in the database.

## Application Setup

### ORCID Setup

This application requires an ORCID-provided "client id" and "client secret".

The application must also be registered with ORCID, and the specific URL
that will be used for callback URL must be specified.

### CAS Setup

For production use, the application also requires the following attributes to
be released to it by CAS:

* employeeNumber
* firstName
* lastName

These attributes are not released by default, so coordination with DIT is
necessary to ensure that these attributes are available to the application.

## Production Environment Configuration

The application uses the "dotenv" gem to configure the environment. The gem
expects a ".env" file in the root directory to contain the environment variables
that are provided to Rails. A sample "env_example" file has been provided to
assist with this process. Simply copy the "env_example" file to ".env" and fill
out the parameters as appropriate.

## Application Monitoring

The application can be monitored using the "/ping" URL path. This path does
not require authentication.

## Development Setup

### ORCID setup

For local development, the application can be configured to use the ORCID
"sandbox" server (https://sandbox.orcid.org/).

See the "ORCID Sandbox IDs" of the "Identities" document on the SSDR Team
drive for information about existing ORCID accounts.

In order to be use the ORCID sandbox server:

1) Log in to ORCID using one of the sandbox ORCID accounts (or create a new
   ORCID account, if necessary).

2) In the account, select the "Developer Tools" tab. If an application has
   never been registered, click the "Register for the free ORCID public API"
   button. Fill out the resulting form. In the "Redirect URIs" section, use

   ```
   http://localhost:3000
   ```

   This will allow any URL starting with "http://localhost:3000" to be used
   as a callback URL.

3) After filling out the form, a "Client ID" and "Client Secret" will be
   displayed. These should be added to the ".env" file for use by the
   application.

### CAS setup

Since the "employeeNumber" CAS attribute is not available without coordination
with DIT, the "uid" attribute (which is the CAS Directory id, and is available
by default) can be used instead. Simply set the "CAS_UID_ATTRIBUTE" in the
".env" to "uid".

The "firstName" and "lastName" attributes are also not available, but their
absence should not cause any errors, other than the user's name not being
displayed.

----
[1]: https://members.orcid.org/api/tutorial/get-orcid-id