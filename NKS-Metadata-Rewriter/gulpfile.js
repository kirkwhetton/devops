const gulp = require('gulp')
const rewrite = require('gulp-nks-rewrite-meta')
const beautify = require('js-beautify').js_beautify

function printSrcPresets() {
  return gulp.src('src/**/*.nksf')
    .pipe(rewrite((file, metadata) => {
      console.info(beautify(JSON.stringify(metadata), { indent_size: 2 }))
      return undefined
    }))
}

function rewriteMetadata() {
  return gulp.src('src/**/*.nksf')
    .pipe(rewrite({
      author: 'Kirk Whetton',
      bankchain: ['Serum 2', 'Cymatics - Apollo', ''],
      comment: 'NKS presets by Kirk Whetton'
    }))
    .pipe(gulp.dest('dist'))
}

function printDistPresets() {
  return gulp.src('dist/**/*.nksf')
    .pipe(rewrite((file, metadata) => {
      console.info(beautify(JSON.stringify(metadata), { indent_size: 2 }))
      return undefined
    }))
}

exports['print-src-presets'] = printSrcPresets
exports['rewrite-metadata'] = rewriteMetadata
exports['print-dist-presets'] = printDistPresets