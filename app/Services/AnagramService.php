<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use RuntimeException;

class AnagramService
{
    /**
     * Trimming+lowercasing strings for better handling
     *
     * @param string $word
     * @return string
     */
    public function makeParseable(string $word): string
    {
        return mb_strtolower(trim($word));
    }

    /**
     * Generate anagrams for the provided word by delegating to the upstream API.
     *
     * @param string $word
     * @return array
     */
    public function findAnagrams(string $word): array
    {
        $parseable = $this->makeParseable($word);

        if ($parseable === '') {
            return [];
        }

        $baseUrl = rtrim((string) config('services.anagram_searcher.base_url'), '/');

        if ($baseUrl === '') {
            throw new RuntimeException('Anagram service URL is not configured.');
        }

        $timeout = (int) config('services.anagram_searcher.timeout', 10);

        $response = Http::timeout($timeout)
            ->acceptJson()
            ->post($baseUrl.'/api/anagrams', [
                'word' => $parseable,
            ]);

        if (!$response->successful()) {
            throw new RuntimeException('Failed to fetch anagrams from upstream service.');
        }

        return (array) data_get($response->json(), 'anagrams', []);
    }
}
