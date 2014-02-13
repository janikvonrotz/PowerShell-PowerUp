var gulp = require('gulp');
var gutil = require('gulp-util');
var markdown = require('gulp-markdown');

gulp.task('default', function () {
    gulp.src('README.md')
        .pipe(markdown())
        .pipe(gulp.dest('./'));
});