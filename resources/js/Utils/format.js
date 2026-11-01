const ID_MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

export const formatNumber = (value, digits = 2) => {
    const num = Number(value ?? 0);
    return new Intl.NumberFormat('id-ID', {
        maximumFractionDigits: digits,
    }).format(num);
};

export const formatRupiah = (value, digits = 0) => {
    const num = Number(value ?? 0);
    return 'Rp ' + new Intl.NumberFormat('id-ID', {
        minimumFractionDigits: digits,
        maximumFractionDigits: digits,
    }).format(num);
};

export const formatDate = (value, fallback = '-') => {
    if (value === null || value === undefined || value === '') {
        return fallback;
    }

    const raw = String(value);
    const dateOnly = raw.match(/^(\d{4})-(\d{2})-(\d{2})(?:T00:00:00(?:\.0+)?Z?)?$/);

    if (dateOnly) {
        const [, year, month, day] = dateOnly;
        return `${Number(day)} ${ID_MONTHS[Number(month) - 1]} ${year}`;
    }

    const date = value instanceof Date ? value : new Date(value);

    if (Number.isNaN(date.getTime())) {
        return fallback;
    }

    return date.toLocaleDateString('id-ID', {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
    });
};

export const formatDateTime = (value, fallback = '-') => {
    if (value === null || value === undefined || value === '') {
        return fallback;
    }

    const date = value instanceof Date ? value : new Date(value);

    if (Number.isNaN(date.getTime())) {
        return formatDate(value, fallback);
    }

    return date.toLocaleString('id-ID', {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
    });
};

export const formatDateLong = (value, fallback = '-') => {
    if (value === null || value === undefined || value === '') {
        return fallback;
    }

    const date = value instanceof Date ? value : new Date(value);

    if (Number.isNaN(date.getTime())) {
        return fallback;
    }

    return date.toLocaleDateString('id-ID', {
        weekday: 'long',
        day: 'numeric',
        month: 'short',
        year: 'numeric',
    });
};

export const formatDateShort = (value, fallback = '-') => {
    if (value === null || value === undefined || value === '') {
        return fallback;
    }

    const date = value instanceof Date ? value : new Date(value);

    if (Number.isNaN(date.getTime())) {
        return fallback;
    }

    return date.toLocaleDateString('id-ID', {
        day: 'numeric',
        month: 'short',
    });
};
