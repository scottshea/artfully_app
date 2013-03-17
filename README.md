# Artful.ly Open Source Edition

Version 1.0.0.rc4

An Open-source application to run your arts organization.  Features include:

* Free and paid ticketing on the web
* Patron tracking
* Patron importing and exporting
* Order tracking
* Door lists
* Box office

And coming soon...

* Advanced patron searching
* [Mailchimp](http://mailchimp.com) integration

# About

Creating your own Artful.ly OSE installation requires a basic understanding of Git, Heroku, Ruby and Rails.

## Dependencies

You'll need the following apps/services to use Artful.ly OSE

* [Solr](http://lucene.apache.org/solr/)
* [MySQL](http://www.mysql.com)
* [Braintree](https://www.braintreepayments.com)
* [S3](http://aws.amazon.com/s3/)

## Prerequisites

Make sure you have the following installed on your system

* [Ruby](http://www.ruby-lang.org)
* [Rubygems](http://docs.rubygems.org/read/chapter/3/)
* [Rails 3.2](http://rubyonrails.org/)
* [Heroku cli](https://github.com/heroku/heroku/)
* [Git](http://git-scm.com/)

Also, before you begin you should set up your production MySQL database.

## Clone the app 

    git clone git@github.com:fracturedatlas/artfully_app.git
    cd artfully_app

### Setup

    gem install foreman
    bundle install

## Database

Update database.yml to point to your mysql database.  Specify a local database and a production database.

Run the migrations

    bundle exec rake artfully_ose_engine:install:migrations
    bundle exec rake db:migrate

## Running Locally

If you intend to do any custom development or testing, go ahead and set up Artful.ly OSE locally on your machine.  If you have no interest in this, feel free to skip ahead to Deployment to Heroku
    
Open a rails console and run

    User.create!({:email => "youradmin@example.com", :password => "your_strong_password", :password_confirmation => "your_strong_password" })
    
### Run

    foreman start
    
Open `http://localhost:5000` in a browser

### Environment

Artful.ly OSE requires the following environment variables to be set if they aren't explicitly set in `config/environment.rb`

    BRAINTREE_MERCHANT_ID
    BRAINTREE_PUBLIC_KEY
    BRAINTREE_PRIVATE_KEY

    S3_BUCKET
    S3_ACCESS_KEY_ID
    S3_SECRET_ACCESS_KEY
    
    WEBSOLR_URL

Additionally these are defaulted in the config.ru and config/unicorn.rb files but can be set in the environment as well
    UNICORN_WORKERS
    UNICORN_TIMEOUT
    UNICORN_BACKLOG
    MAX_REQUEST_MIN *used by unicorn killer*
    MAX_REQUEST_MAX *used by unicorn killer*
    OOM_MIN *used by unicorn killer*
    OOM_MAX *used by unicorn killer*

## Deployment to Heroku

### About delayed_job

Artful.ly OSE ships with `delayed_job` disabled.  If you do have a Heroku worker turned on, you'll want to enable delayed_jobs.

To enable `delayed_job`, in `config/application.rb` change this line to read

    Delayed::Worker.delay_jobs = true
    
__Please note__ that Artful.ly OSE depends on delayed jobs for locking tickets while a patron is checking out.  Leaving delayed jobs disabled prevents tickets from being locked.  Checkout will still work, but tickets will not be reserved for a patron while he/she is checking out.

### Sending email

Artful.ly OSE __WILL NOT PROCESS TRANSACTIONS WITHOUT A VALID SMTP SETUP__ We will make this more flexible in a future release.

A good option is to enable SendGrid.  SendGrid has a free usage tier which integrates with Heroku.  See the note in `Setup SendGrid` to enable SendGrid.  Artful.ly OSE will work with SendGrid without any modification necessary.

Otherwise, you'll need to specify your smtp settings in `config/environments/production.rb` under `config.action_mailer.smtp_settings`

Finaly, regardless of smtp provider, __YOU MUST__ edit the file `config/environments/production.rb` and change the value of `config.action_mailer.default_url_options` to match your hostname.

    config.action_mailer.default_url_options={:host => 'myapp.herokuapp.com'}
    
or if you own your own domain
    
    config.action_mailer.default_url_options={:host => 'www.myexampletheater.com'}

### Push 

Follow the [Heroku instructions](https://devcenter.heroku.com/articles/creating-apps) for creating an app

    heroku apps:create myapp
    git add .
    git commit -m "Prepping push to Heroku"
    git push heroku master
    
### Setup SendGrid (Optional)

If you're using SendGrid to send email, enable the starter plan with the following command:

    heroku addons:add sendgrid:starter

See the [SendGrid documentation](https://addons.heroku.com/sendgrid) for more information.

### Setup the production database

Before running this, you must have setup and configured a MySQL database.  If you database is on Amazon's RDS, you'll have to enable that plugin on Heroku by running

    heroku addons:add amazon_rds
    heroku config:add DATABASE_URL=mysql2://username:password@url.ofyourdatabase.com/databaseName

Otherwise, make sure you have edited, committed, and pushed your database.yml file

    heroku run bundle exec rake db:migrate
    
Please note that you must first have run and committed `bundle exec rake artfully_ose_engine:install:migrations` from the above steps

### Set environment variables

If you didn't set environment variables in `config/environment.rb`, you'll need to set them on the heroku command line.  Run this command for each environment variable listed in "Environment"
    
    heroku config:add BRAINTREE_MERCHANT_ID='...'
    
If you have a Google Analytics account, you can set the environment variables `GA_ACCOUNT` and `GA_DOMAIN` to enable Google Analytics in Artful.ly OSE.

### Create your first user

This user will be the organization administrator.  In a Heroku console, run

    User.create!({:email => "youradmin@example.com", :password => "your_strong_password", :password_confirmation => "your_strong_password" })

### Restart the app

    heroku restart
  
### Load your application

Go to `http://myapp.herokuapp.com` in a web browser
