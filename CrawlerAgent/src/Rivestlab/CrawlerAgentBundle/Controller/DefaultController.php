<?php

namespace Rivestlab\CrawlerAgentBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class DefaultController extends Controller
{
    public function indexAction($name='TestName')
    {
        return $this->render('RivestlabCrawlerAgentBundle:Default:index.html.twig', array('name' => $name));
    }
}
