<?php

namespace Rivestlab\CrawlerAgentBundle\Menu;

use Knp\Menu\FactoryInterface;
use Symfony\Component\DependencyInjection\ContainerAware;

class TopMenu extends ContainerAware
{
    public function mainMenu(FactoryInterface $factory, array $options)
    {
        $menu = $factory->createItem('root');

        $menu->addChild('Home', array('route' => 'rivestlab_crawler_agent_homepage'));
        $menu->addChild('Car', array('route' => 'rivestlab_car_homepage',
            'routeParameters' => array('name' => 2)));

        /*
        $menu->addChild('About Me', array(
            'route' => 'page_show',
            'routeParameters' => array('id' => 42)
        ));*/
        // ... add more children

        return $menu;
    }
}