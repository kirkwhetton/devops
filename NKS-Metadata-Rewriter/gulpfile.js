const gulp = require('gulp')
const rewrite = require('gulp-nks-rewrite-meta')
const beautify = require('js-beautify').js_beautify
const path = require('path')

function printSrcPresets() {
  return gulp.src('src/**/*.nksf')
    .pipe(rewrite((file, metadata) => {
      console.info(beautify(JSON.stringify(metadata), { indent_size: 2 }))
      return undefined
    }))
}

//function rewriteMetadata() {
//  return gulp.src('src/**/*.nksf')
//    .pipe(rewrite({
//      author: 'Kirk Whetton',
//      bankchain: ['Serum 2', 'Cymatics - Black Pop Collection', ''],
//      comment: 'NKS presets by Kirk Whetton'
//    }))
//   .pipe(gulp.dest('dist'))
//}

function printDistPresets() {
  return gulp.src('dist/**/*.nksf')
    .pipe(rewrite((file, metadata) => {
      console.info(beautify(JSON.stringify(metadata), { indent_size: 2 }))
      return undefined
    }))
}

// ...existing code...

function rewriteMetadata() {
  let config
  try {
    config = require('./banks.json') // map of maps
  } catch (err) {
    console.error('Could not load banks.json:', err.message)
    return Promise.reject(err)
  }

  const tasks = []

  for (const [key, conf] of Object.entries(config)) {
    // build bankchain as strings (accepts objects or strings)
    const bankchain = Array.isArray(conf.bankchain)
      ? conf.bankchain.map(b => typeof b === 'string' ? b : (b.instrument + (b.bank ? ' - ' + b.bank : '')))
      : []

    // exclude folder (and any other keys the plugin doesn't accept) from metadata
    const { folder, ...metaFromConf } = conf
    const metadata = Object.assign({}, metaFromConf, { bankchain })

    const srcGlob = folder ? path.posix.join('src', folder, '**', '*.nksf') : 'src/**/*.nksf'
    const destFolder = folder ? path.posix.join('dist', folder) : 'dist'

    const stream = gulp.src(srcGlob)
      .pipe(rewrite(metadata))
      .pipe(gulp.dest(destFolder))

    tasks.push(new Promise((resolve, reject) => {
      stream.on('finish', resolve)
      stream.on('end', resolve)
      stream.on('error', reject)
    }))
  }

  return Promise.all(tasks)
}

exports['print-src-presets'] = printSrcPresets
exports['rewrite-metadata'] = rewriteMetadata
exports['print-dist-presets'] = printDistPresets