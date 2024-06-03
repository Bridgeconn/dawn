import { Tabs } from 'expo-router';
import React from 'react';

import { TabBarIcon } from '@/components/navigation/TabBarIcon';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

export default function TabLayout() {
  const colorScheme = useColorScheme();

  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: Colors[colorScheme ?? 'light'].tint,
        headerShown: false,
      }}>
      <Tabs.Screen
        name="index"
        options={{ title: 'User',
          tabBarIcon: ({ color, focused }) => (
            <TabBarIcon name={focused ? 'person' : 'person-outline'} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="home"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, focused }) => (
            <TabBarIcon name={focused ? 'home' : 'home-outline'} color={color} />
          ),
        }}
      />
      <Tabs.Screen
      name="text"
      options={{
        title: 'Text',
        tabBarIcon: ({ color, focused }) => (
          <TabBarIcon name={focused ? 'keypad' : 'keypad-outline'} color={color} />
        ),
      }}
    />
    <Tabs.Screen
      name="audio"
      options={{
        title: 'Audio',
        tabBarIcon: ({ color, focused }) => (
          <TabBarIcon name={focused ? 'musical-notes' : 'musical-notes'} color={color} />
        ),
      }}
    />
     <Tabs.Screen
      name="menu"
      options={{
        title: 'Menu',
        tabBarIcon: ({ color, focused }) => (
          <TabBarIcon name={focused ? 'menu' : 'menu-outline'} color={color} />
        ),
      }}
    />
    </Tabs>
  );
}
