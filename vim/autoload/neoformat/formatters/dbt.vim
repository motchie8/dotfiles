function! neoformat#formatters#dbt#enabled() abort
    return ['shandy_sqlfmt']
endfunction

function! neoformat#formatters#dbt#shandy_sqlfmt() abort
    return {
        \ 'exe': 'sqlfmt',
        \ 'args': ['-'],
        \ 'stdin': 1
        \ }
endfunction
