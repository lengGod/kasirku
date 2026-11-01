import { usePage } from '@inertiajs/vue3';

export function useAuthorization() {
    const page = usePage();

    const can = (ability) => Boolean(page.props.auth?.can?.[ability]);

    return { can };
}
