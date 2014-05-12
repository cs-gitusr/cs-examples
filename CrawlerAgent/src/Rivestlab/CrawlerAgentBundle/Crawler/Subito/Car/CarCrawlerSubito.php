<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

namespace Rivestlab\CrawlerAgentBundle\Crawler\Subito\Car;

use Symfony\Component\DependencyInjection\ContainerAwareInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\EventDispatcher\Event;
use Symfony\Component\EventDispatcher\EventDispatcher;
use Symfony\Component\DomCrawler\Crawler;
use Goutte\Client;
use Rivestlab\CarBundle\Entity\Car;

/**
 * Description of CarCrawlerSubito
 *
 * @author 
 */
class CarCrawlerSubito extends EventDispatcher implements ContainerAwareInterface
{
    //put your code here

    /**
     * @var string The base url
     */
    public $url;

    /**
     * @var \Goutte\Client The client browser (Goutte)
     */
    private $client;

    /**
     * @var \Symfony\Component\DomCrawler\Crawler The crawler gently provided by symfony
     */
    private $crawler;

    /**
     * @var ContainerInterface
     */
    protected $container;

    /**
     * @var int Current page index
     */
    public $pageIndex = 0;

    /**
     * @var int Max number of pages to parse
     */
    public $maxPages = 20;

    /**
     * @var int Current page index
     */
    public $crawledEntries = 0;
    public $maxEntries = 10;

    /**
     * The maxpages.overlap event is thrown when the max number of pages
     * (of the paginator) are crawled.
     *
     * The event listener receives a generic
     * Event instance.
     *
     * @var string
     */

    const MAXPAGES_OVERLAP = "maxpages.overlap";

    /**
     * The entries.overlap event is thrown when the max number of entries
     * are crawled.
     *
     * The event listener receives a generic
     * Event instance.
     *
     * @var string
     */
    const MAXENTRIES_OVERLAP = "maxentries.overlap";
    const NEXTPAGE_READY = "nextpage.ready";
    const ENTRY_CRAWLED = "entry.crawled";
    const ALLPAGES_CRAWLED = "allpages.crawled";
    const FINISH_EVENT = "finish.event";

    public function setContainer(ContainerInterface $container = null)
    {
        $this->container = $container;
    }

    public function init()
    {
        $this->addListener(self::MAXPAGES_OVERLAP, array($this, 'onMaxPagesOverlap'));
        $this->addListener(self::MAXENTRIES_OVERLAP, array($this, 'onMaxEntriesOverlap'));
        $this->addListener(self::NEXTPAGE_READY, array($this, 'onNextPageReady'));
        $this->addListener(self::ENTRY_CRAWLED, array($this, 'onEntryCrawled'));
    }

    public function clear()
    {
        $this->removeListener(self::MAXPAGES_OVERLAP, array($this, 'onMaxPagesOverlap'));
        $this->removeListener(self::MAXENTRIES_OVERLAP, array($this, 'onMaxEntriesOverlap'));
        $this->removeListener(self::NEXTPAGE_READY, array($this, 'onNextPageReady'));
        $this->removeListener(self::ENTRY_CRAWLED, array($this, 'onEntryCrawled'));
    }

    public function run()
    {
        $this->init();
        $this->walkToTheFirstPage();
        $this->dispatch(self::NEXTPAGE_READY);
    }

    public function onMaxPagesOverlap(Event $event)
    {
        $this->finish();
    }

    public function onMaxEntriesOverlap(Event $event)
    {
        $this->finish();
    }

    public function finish()
    {
        $this->clear();
        $this->dispatch(self::FINISH_EVENT);
    }

    public function onNextPageReady(Event $event)
    {
        $this->loopOverPageEntries();
        $this->nextPage();
    }

    public function onEntryCrawled(Event $event)
    {
        //$event->
        //$this->storeEntry();
    }

    private function walkToTheFirstPage()
    {
        $this->client = new Client();
        $this->crawler = $this->client->request('GET', $this->url);

        $form = $this->crawler->selectButton('Cerca')->form();
        $form['c'] = 2; //'Auto';
        $form['w'] = 9; //'PR';

        $this->crawler = $this->client->submit($form);
    }

    private function loopOverPageEntries()
    {
        $links = $this->crawler->filterXPath('//div[@class="th_box"]/a')->links();
        foreach ($links as $link) {
            $this->crawledEntries++;
            if ($this->crawledEntries > $this->maxEntries) {
                return $this->dispatch(self::MAXENTRIES_OVERLAP);
            }
            $this->extractEntryInfo($link->getUri());
        }
    }

    /**
     * Get Next Page Uri.
     */
    private function nextPage()
    {
        try {
            $this->pageIndex++;
            if ($this->pageIndex > $this->maxPages) {
                return $this->dispatch(self::MAXPAGES_OVERLAP);
            }

            $link = $this->crawler
                            ->filterXPath('//div[@class="pagination"]/div/strong')
                            ->nextAll()->first()->link();
            $uri = $link->getUri();
            $crawler = $this->client->request('GET', $uri);
        } catch (Exception $e) {
            return $this->dispatch(self::ALLPAGES_CRAWLED);
        }
    }

    private function extractEntryInfo($entryUrl)
    {
        $crawler = $this->client->request('GET', $entryUrl);

        $map = array();
        $nodes = $crawler
                ->filterXPath('//div[@class="annuncio_info"]/ul/li/b')
                ->each(function(\DOMElement $node, $i) use (&$map) {
                    $allText = $node->parentNode->nodeValue;
                    $theKey = $node->nodeValue;
                    $theVal = str_replace($theKey, '', $allText);
                    $map[$theKey] = $theVal;
                });

        $this->dispatch(self::ENTRY_CRAWLED);

        $car = new Car();
        $car->setName($map['Modello']);
        $car->setPrice($map['Prezzo']);
        $car->setDescription($map['']); //Use OptionsResolver
        $em = $this->container->get('doctrine');
        // ... em->save
    }

}

?>
