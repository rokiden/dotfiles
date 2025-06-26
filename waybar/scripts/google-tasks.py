#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Modified from Google Calendar API sample for Google Tasks API
# Original Copyright 2014 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Waybar module for Google Tasks API.
Shows the number of incomplete tasks in a specified list."""

import os
import sys
import json
import argparse
from googleapiclient import sample_tools
from oauth2client import client

def main(argv):
    os.chdir(os.sep.join(os.path.realpath(__file__).split(os.sep)[:-1]))
    parser = argparse.ArgumentParser(description='Google Tasks count for Waybar')
    parser.add_argument('--list-name', help='Name of the task list to show', default=None)
    parser.add_argument('--max-tooltip-items', type=int, help='Maximum number of tasks to show in tooltip', default=10)
    args, unknown_args = parser.parse_known_args(argv[1:])
    
    # Keep only the script name and known args for sample_tools.init
    init_args = [argv[0]] + unknown_args
    
    # Authenticate and construct service
    service, flags = sample_tools.init(
        init_args,
        "tasks",
        "v1",
        __doc__,
        __file__,
        scope="https://www.googleapis.com/auth/tasks.readonly",
    )
    
    try:
        # Get all task lists
        tasklists_result = service.tasklists().list().execute()
        tasklists = tasklists_result.get('items', [])
        
        if not tasklists:
            output = {
                'text': '0',
                'tooltip': 'No task lists found',
                'class': 'no-tasks'
            }
            print(json.dumps(output))
            return
        
        # Find the specified list or use the first one
        target_list = None
        if args.list_name:
            for tasklist in tasklists:
                if tasklist['title'].lower() == args.list_name.lower():
                    target_list = tasklist
                    break
                
            if not target_list:
                output = {
                    'text': '?',
                    'tooltip': f'List "{args.list_name}" not found',
                    'class': 'list-not-found'
                }
                print(json.dumps(output))
                return
        else:
            target_list = tasklists[0]
        
        # Get incomplete tasks in the list
        tasks_result = service.tasks().list(
            tasklist=target_list['id'],
            showCompleted=False
        ).execute()
        
        tasks = tasks_result.get('items', [])
        count = len(tasks)
        
        # Determine CSS class
        css_class = 'has-tasks' if count > 0 else 'no-tasks'
        
        # Build tooltip with task list
        tooltip = f"{count} task{'s' if count != 1 else ''} in \"{target_list['title']}\":"
        
        if count > 0:
            # Add individual tasks to tooltip
            tooltip += "\n\n"
            max_items = min(count, args.max_tooltip_items)
            
            for i in range(max_items):
                task_title = tasks[i].get('title', 'Untitled task')
                tooltip += f"• {task_title}\n"
                
            if count > args.max_tooltip_items:
                tooltip += f"\n...and {count - args.max_tooltip_items} more"
        output = {
            'text': str(count),
            'tooltip': tooltip,
            'class': css_class
        }
        print(json.dumps(output,ensure_ascii=False))
            
    except client.AccessTokenRefreshError:
        output = {
            'text': '!',
            'tooltip': 'The credentials have been revoked or expired, please re-run the application to re-authorize',
            'class': 'error'
        }
        print(json.dumps(output))

if __name__ == "__main__":
    main(sys.argv)

