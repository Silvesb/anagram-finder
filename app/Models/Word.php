<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Word extends Model
{
    protected $table = 'wordbase';

    public $timestamps = false;

    protected $fillable = [
        'word',
        'signature',
    ];
}
