# Alma Digital Flowpaper Viewer

A Docker image which can be used to deploy the [FlowPaper viewer](https://flowpaper.com) as an [Alma Digital viewer](https://www.exlibrisgroup.com/Alma). 

For more information, see this [blog post](https://developers.exlibrisgroup.com/blog/Implementing-a-Custom-Viewer-for-PDF-Files).

## Deployment

This Docker image is optimized for deplyment to [Heroku](http://heroku.com/) and uses this PHP + nginx [base image](https://hub.docker.com/r/ttskch/nginx-php-fpm-heroku/). To deploy this viewer to Heroku, do the following:
```
$ heroku container:login
$ heroku create
$ heroku container:push web --app {APP NAME}
$ heroku config:set ALMA_API_KEY=XXX AWS_ACCESS_KEY_ID=XXX AWS_SECRET_ACCESS_KEY=XXX --app {APP NAME}
$ heroku open --app {APP NAME}
```

### Environment Variables

The following environment variables are required:
* `ALMA_API_KEY`: An API key which has read permissions on the BIB APIs
* `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY`: These are used by the AWS SDK to access files in S3 storage. These values can be retrieved in the Alma digital storage configuration.

### Local Development

To modify this repository locally, you can `git clone https://github.com/jweisman/almad-flowpaper.git` to a local directory. To build the image use

```
docker build -t almad-flowpaper .
```

To run the container locally, use: 

```
docker run -d --rm -p 8080:5000 -e PORT=5000 -e ALMA_API_KEY={API Key} -e AWS_ACCESS_KEY_ID={AWS Key} -e AWS_SECRET_ACCESS_KEY={AWS Secret} --name flowpaper almad-flowpaper
```

The access the viewer using http://localhost:8080/flowpaper/php/alma.php?rep_id={representation_id}
