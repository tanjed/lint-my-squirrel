<?php

/**
 * PHP CS Fixer — Selection Linter Rules
 *
 * Rules:
 *  1. Trailing comma after every array element
 *  2. Space before and after if condition parentheses
 *  3. Imports sorted by length (shortest first)
 *  4. Method/class opening brace on the next line
 *  5. Remove unnecessary blank lines and spaces
 *  6. No blank line after closing } or end of if block
 *  7. Space before { and before ()
 */

$finder = PhpCsFixer\Finder::create()
    ->in(__DIR__)
    ->exclude(['vendor', 'node_modules', 'storage', 'bootstrap/cache'])
    ->name('*.php');

return (new PhpCsFixer\Config())
    ->setRiskyAllowed(true)
    ->setRules([

        // 1. Trailing comma after every array element
        'trailing_comma_in_multiline'    => ['elements' => ['arrays', 'arguments', 'parameters']],
        'no_trailing_comma_in_singleline'=> true,

        // 2. Space inside if ( condition ) parentheses
        'no_spaces_inside_parenthesis'   => false,
        'spaces_inside_parentheses'      => ['space' => 'single'],

        // 3. Imports sorted by length, shortest first
        'ordered_imports'                => ['sort_algorithm' => 'length', 'imports_order' => ['class', 'function', 'const']],
        'no_unused_imports'              => true,
        'single_import_per_statement'    => true,
        'no_leading_import_slash'        => true,

        // 4. Opening brace on the next line for methods/classes
        'braces_position'                => [
            'functions_opening_brace'            => 'next_line_unless_newline_at_signature_end',
            'classes_opening_brace'              => 'next_line_unless_newline_at_signature_end',
            'anonymous_functions_opening_brace'  => 'same_line',
            'anonymous_classes_opening_brace'    => 'next_line_unless_newline_at_signature_end',
            'control_structures_opening_brace'   => 'same_line',
        ],

        // 5. Remove unnecessary blank lines and spaces
        'no_extra_blank_lines' => [
            'tokens' => [
                'extra',                  // multiple consecutive blank lines → one
                'blank_line_before_statement', // no blank line before return/throw etc when unnecessary
                'curly_brace_block',      // no blank line at start/end of { } block
                'parenthesis_brace_block',// no blank line inside ( )
                'square_brace_block',     // no blank line inside [ ]
                'throw',
                'use',
            ],
        ],
        'no_whitespace_in_blank_line'            => true,  // strip spaces on blank lines
        'no_trailing_whitespace'                 => true,  // strip trailing spaces on every line
        'compact_nullable_type_declaration'      => true,  // remove space in ?Type
        'no_spaces_after_function_name'          => true,  // fn() not fn ()

        // 6. No blank line after closing } or after if/else/for blocks
        'no_blank_lines_after_class_opening'     => true,  // no blank after class {
        'no_blank_lines_after_phpdoc'            => true,  // no blank between docblock and declaration
        'class_attributes_separation'            => [
            'elements' => [
                'method'   => 'one',   // exactly one blank line between methods
                'property' => 'none',  // no blank lines between property declarations
            ],
        ],
        'function_declaration'                   => [
            'closure_function_spacing'    => 'none',
            'closure_fn_spacing'          => 'none',
        ],

        // 7. Space before { and before ()
        // Ensures: function foo() {  →  space before {
        //          if ($x){         →  if ($x) {
        //          function foo(){  →  function foo() {
        'space_before_semicolon'                 => false, // don't add space before ;
        'single_space_around_construct'          => [
            'constructs_followed_by_a_single_space' => [
                'abstract', 'as', 'attribute', 'break', 'case', 'catch',
                'class', 'clone', 'comment', 'const', 'const_import',
                'continue', 'do', 'echo', 'else', 'elseif', 'enum',
                'extends', 'finally', 'for', 'foreach', 'function',
                'function_import', 'if', 'implements', 'include',
                'include_once', 'instanceof', 'insteadof', 'interface',
                'match', 'named_argument', 'new', 'open_tag_with_echo',
                'php_open', 'print', 'require', 'require_once', 'return',
                'static', 'switch', 'throw', 'trait', 'try', 'type_colon',
                'use', 'use_lambda', 'use_trait', 'var', 'while', 'yield',
                'yield_from',
            ],
        ],


        '@PSR12'       => true,
        'array_syntax' => ['syntax' => 'short'],
        'single_quote' => true,
    ])
    ->setFinder($finder)
    ->setCacheFile(sys_get_temp_dir() . '/.php-cs-fixer.cache');
