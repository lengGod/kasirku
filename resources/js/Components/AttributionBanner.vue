<script setup>
import { ExternalLink } from '@lucide/vue';
</script>

<template>
    <div class="h-9 bg-lime flex items-center justify-center px-4 flex-shrink-0">
        <p class="text-[10px] sm:text-xs font-semibold text-ink tracking-wide flex items-center gap-1.5 whitespace-nowrap">
            Properti milik
            <a
                href="https://www.lengworks.com/"
                target="_blank"
                rel="noopener noreferrer"
                class="underline underline-offset-2 hover:text-violet-text transition inline-flex items-center gap-1"
            >
                lengworks.com
                <ExternalLink class="w-3 h-3" />
            </a>
        </p>
    </div>
</template>
