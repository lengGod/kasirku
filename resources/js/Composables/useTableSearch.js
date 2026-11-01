import { ref, watch } from 'vue';

export function useTableSearch(onSearch, delay = 300, initial = '') {
    const search = ref(initial);
    let timer = null;

    watch(search, (value) => {
        clearTimeout(timer);
        timer = setTimeout(() => {
            onSearch(String(value ?? '').trim());
        }, delay);
    });

    return search;
}
