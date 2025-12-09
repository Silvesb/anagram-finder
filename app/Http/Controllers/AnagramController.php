<?php

namespace App\Http\Controllers;

use App\Services\AnagramService;
use Illuminate\Http\Request;

class AnagramController extends Controller
{

    /**
     * Handle anagram finding
     *
     * @param Request $request JSON string
     * @param AnagramService $service
     *
     * @return string JSON response
     */
    public function find(Request $request, AnagramService $service)
    {
        $data = $request->validate([
            'word' => ['required', 'string'],
        ]);

        $parseable = $service->makeParseable($data['word']);

        if ($parseable === '') {
            return response()->json([
                'word' => '',
                'anagrams' => [],
            ]);
        }

        return response()->json([
            'word' => $parseable,
            'anagrams' => $service->findAnagrams($parseable),
        ]);
    }
}
