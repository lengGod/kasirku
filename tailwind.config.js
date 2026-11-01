import defaultTheme from 'tailwindcss/defaultTheme';
import forms from '@tailwindcss/forms';

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
        './resources/js/**/*.vue',
    ],

    theme: {
        borderRadius: {
            none: '0',
            DEFAULT: '0',
        },
        extend: {
            colors: {
                ink: { DEFAULT: '#14123A', 2: '#1F1C54', 3: '#2E2B73' },
                canvas: '#EEF0F6',
                surface: { DEFAULT: '#FFFFFF', 2: '#F6F7FB' },
                line: '#D5D7E6',
                muted: '#4A4770',
                lime: '#C6F432',
                violet: { DEFAULT: '#7B61FF', text: '#5A3FD6' },
                ok: { bg: '#D2F3E0', fg: '#1B5A3A' },
                warn: { bg: '#FFE7A8', fg: '#5E4300' },
                bad: { bg: '#FFD3C7', fg: '#7A2410' },
                info: { bg: '#E4DEFF', fg: '#3B2A9A' },
                adj: { bg: '#FFE0D2', fg: '#7A3A22' },
                hi: '#EFFBB8',
            },
            boxShadow: {
                hard: '6px 6px 0 #14123A',
            },
            fontFamily: {
                display: ['"Bricolage Grotesque"', 'system-ui', 'sans-serif'],
                sans: ['"Plus Jakarta Sans"', 'system-ui', 'sans-serif'],
            },
        },
    },

    plugins: [forms],
};
